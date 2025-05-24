import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:wiqaya_app/models/user.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late MapboxMap _mapController;
  final ApiClient _apiClient = ApiClient();
  List<Map<String, double>> _routePoints = [];
  bool _isLoading = false;
  String _distance = '';
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    //_getUserLocationAndRoute();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppointmentController>(context);
    final appointment = controller.selectedAppointment!;

    // Create camera position focused on the appointment center
    double centerLng = appointment.center!.longitude!;
    double centerLat = appointment.center!.latitude!;

    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(centerLng, centerLat)),
      zoom: 14.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appointment_details,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        padding: EdgeInsets.only(top: 10.w),
        child: Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 200.h,
                  child: MapWidget(
                    styleUri: MapboxStyles.MAPBOX_STREETS,
                    cameraOptions: camera,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _getUserLocationAndRoute();
                      _setAnnotation(_mapController, appointment);
                    },
                  ),
                ),
              ),
              Center(
                child: Text(appointment.center!.name!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 25.sp),),
              ),
              _buildStatus(context),
              ListTile(
                leading: Text('${AppLocalizations.of(context)!.distance}: ', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                title: Text(_isLoading ? AppLocalizations.of(context)!.calculating : _distance, style: Theme.of(context).textTheme.bodyLarge!),
              ),
              ListTile(
                leading: Text('${AppLocalizations.of(context)!.date}: ', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                title: Text(intl.DateFormat('yyyy/MM/dd').format(appointment.schedule?.date ?? DateTime.now()), style: Theme.of(context).textTheme.bodyLarge!),
              ),
              ListTile(
                leading: Text('${AppLocalizations.of(context)!.working_hours}: ', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                title: Text('${intl.DateFormat('HH:mm ').format(appointment.schedule?.beginAt ?? DateTime.now())}${AppLocalizations.of(context)!.to} ${intl.DateFormat('HH:mm').format(appointment.schedule?.endAt ?? DateTime.now())}', style: Theme.of(context).textTheme.bodyLarge!),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.3.w,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(HugeIcons.strokeRoundedVaccine, color: Theme.of(context).secondaryHeaderColor),
                title: Text(appointment.vaccine?.name ?? '', style: Theme.of(context).textTheme.bodyLarge!),
              ),
              ListTile(
                leading: Icon(Icons.person_rounded, color: Theme.of(context).secondaryHeaderColor),
                title: Text(_setName(), style: Theme.of(context).textTheme.bodyLarge!),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setUserAnnotation(MapboxMap mapboxMap, Point point) async {
    // Load the image from assets
    final ByteData bytes = await rootBundle.load(
      'assets/icons/user_position_icon.png',
    );
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Create a PointAnnotationOptions
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(point.coordinates.lng, point.coordinates.lat),
      ), // Example coordinates
      image: imageData,
      iconSize: 0.25,
    );

    // Add the annotation to the map
    _pointAnnotationManager!.deleteAll();
    _pointAnnotationManager!.create(pointAnnotationOptions);
  }

  Future<void> _getUserLocationAndRoute() async {
    setState(() {
      _isLoading = true;
    });
    final controller = Provider.of<AppointmentController>(context, listen: false);
    final appointment = controller.selectedAppointment!;
    final centerLat = appointment.center!.latitude!;
    final centerLng = appointment.center!.longitude!;
    // Get user location
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    _pointAnnotationManager = await _mapController!.annotations.createPointAnnotationManager();
    if (!serviceEnabled || permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }
    final position = await geo.Geolocator.getCurrentPosition();
    _setUserAnnotation(_mapController!, Point(coordinates: Position(position.longitude, position.latitude)));
    // Build Mapbox Directions API URL
    final accessToken =
        'pk.eyJ1IjoibW91bmlyYmFkbGlzMiIsImEiOiJjbTl6emg5YjgwaGRyMmxzZng1cTkxa256In0.FCAWFO7Iqz5t4u2dGqSDwA'; // Replace with real token
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${position.longitude},${position.latitude};$centerLng,$centerLat?geometries=geojson&access_token=$accessToken';

    try {
      final response = await _apiClient.get(url);
      final data = response.data;

      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      List<Map<String, double>> points = [];
      setState(() {
        if (data['routes'][0]['distance'] < 1000) {
          _distance = '${data['routes'][0]['distance'].toStringAsFixed(1)} ${AppLocalizations.of(context)!.m}';
        } else {
          _distance = '${(data['routes'][0]['distance'] / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}';
        }
      });
      for (var coord in coordinates) {
        double lng = (coord[0] as num).toDouble();
        double lat = (coord[1] as num).toDouble();
        points.add({'lng': lng, 'lat': lat});
      }
      setState(() {
        _routePoints = points;
      });

      _addRouteLineToMap(_routePoints);
    } on DioException catch (e) {
      print('Error fetching route: ${e.response?.data}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addRouteLineToMap(List<Map<String, double>> points) async {
    final geoJson = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": points.map((p) => [p['lng']!, p['lat']!]).toList(),
          },
          "properties": {},
        },
      ],
    };

    try {
      // Simple implementation to add a line on the map
      String sourceId = 'route-source';
      String layerId = 'route-layer';

      // Check if layer exists and remove it
      if (await _mapController.style.styleLayerExists(layerId)) {
        await _mapController.style.removeStyleLayer(layerId);
      }

      // Check if source exists and remove it
      if (await _mapController.style.styleSourceExists(sourceId)) {
        await _mapController.style.removeStyleSource(sourceId);
      }

      // Add GeoJSON source
      String sourceJson = jsonEncode({'type': 'geojson', 'data': geoJson});
      await _mapController.style.addStyleSource(sourceId, sourceJson);

      // Add line layer
      String layerJson = jsonEncode({
        'id': layerId,
        'type': 'line',
        'source': sourceId,
        'layout': {'line-join': 'round', 'line-cap': 'round'},
        'paint': {
          'line-color': '#FF0000',
          'line-width': 4,
          'line-opacity': 0.8,
        },
      });
      await _mapController.style.addStyleLayer(layerJson, null);
    } catch (e) {
      print('Error adding route to map: $e');
    }
  }

  Future<void> _setAnnotation(MapboxMap mapboxMap, Appointment appointment) async {
    final pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Load the image from assets
    final ByteData bytes = await rootBundle.load(
      'assets/icons/hospital_location_icon.png',
    );
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Create a PointAnnotationOptions
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(
          appointment.center!.longitude!,
          appointment.center!.latitude!,
        ),
      ), // Example coordinates
      image: imageData,
      iconSize: 0.25,
      textField: appointment.center!.name,
    );

    // Add the annotation to the map
    pointAnnotationManager.create(pointAnnotationOptions);
  }

 Widget _buildStatus(BuildContext context) {
    final appintment = Provider.of<AppointmentController>(context).selectedAppointment!;
    switch (appintment.status) {
      case 1:
        return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.yellow,
          ),
          child: Text(AppLocalizations.of(context)!.pending, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      case 2:
        return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue,
          ),
          child: Text(AppLocalizations.of(context)!.confirmed, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      case 3:
        return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.green,
          ),
          child: Text(AppLocalizations.of(context)!.completed, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      case 4:
        return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
          ),
          child: Text(AppLocalizations.of(context)!.cancelled, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      default:
        return Container(
          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.yellow,
          ),
          child: Text(AppLocalizations.of(context)!.pending, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
    }
  }
  String _setName() {
  
    final appointment = Provider.of<AppointmentController>(context).selectedAppointment!;
    if (appointment.firstName == null) {
      return '${User.user?.firstName} ${User.user?.familyName}';
    } else {
      // Manually concatenate 'For: ' with the names to avoid using the reserved keyword
      return '${appointment.firstName} ${appointment.familyName}';
    }
  }
}
