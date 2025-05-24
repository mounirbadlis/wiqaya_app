import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/controllers/reminder_controller.dart';
import 'package:wiqaya_app/models/recommendation_result.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/reminder.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FindingNearestCenterScreen extends StatefulWidget {
  FindingNearestCenterScreen({super.key});

  @override
  State<FindingNearestCenterScreen> createState() => _FindingNearestCenterScreenState();
}

class _FindingNearestCenterScreenState extends State<FindingNearestCenterScreen> {

  MapboxMap? _mapController;
  bool _isLoading = false;
  List<Map<String, double>> _routePoints = [];
  Point _selectedPoint = Point(coordinates: Position(10.6328, 36.8902));
  RecommendationResult? _selectedCenter;
  late PointAnnotationManager _pointAnnotationManager;
  late PointAnnotationManager _centerAnnotationManager;
  late final Reminder _reminder;
  CameraOptions initialCamera = CameraOptions(
    center: Point(coordinates: Position(10.6328, 36.8902)),
    zoom: 7.0,
  );
  @override
  void initState() {
    super.initState();
    final controller = Provider.of<ReminderController>(context, listen: false);
    _reminder = controller.selectedReminder!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: Text(AppLocalizations.of(context)!.finding_nearest_center, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        padding: EdgeInsets.only(top: 10.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 200.h,
                  child: MapWidget(
                    styleUri: MapboxStyles.MAPBOX_STREETS,
                    cameraOptions: initialCamera,
                    onMapCreated: (controller) async {
                      _mapController = controller;
                      _centerAnnotationManager = await _mapController!.annotations.createPointAnnotationManager();
                      _setInitialLocation(context);
                    },
                    onLongTapListener: _onMapTap,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Consumer<AppointmentController>(
                    builder: (context, controller, _) {
                      if (controller.isAvailableCentersLoading) {
                        return const CustomCircularIndicator();
                      } else if (controller.isAvailableCentersError) {
                        return ErrorRetryWidget(
                          message: AppLocalizations.of(context)!.error_server,
                          onRetry: () {
                            _setInitialLocation(context);
                          },
                        );
                      } else if(controller.centersWithDistance.isEmpty) {
                        return Center(
                          child: Text(AppLocalizations.of(context)!.no_centers_found),
                        );
                      }
                      return Column(
                        children: [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.receiver, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text(_buildReceiverName()),
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.vaccine, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text(_reminder.vaccineName ?? ''),
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.date, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text(intl.DateFormat('yyyy-MM-dd').format(_reminder.bookAfter!)),
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text('${_selectedCenter?.centerName} - (${_calculateDistance(Provider.of<AppointmentController>(context).centersWithDistance[0]['distance']!)})'),
                          ),
                          Spacer(),
                          if(_selectedCenter != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).secondaryHeaderColor,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(strokeWidth: 1.sp, color: Colors.white)
                                  : Text(
                                      AppLocalizations.of(context)!.book_appointment,
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }

  String _buildReceiverName() {
    if (_reminder.childId != null) {
      return '${_reminder.childFirstName} ${_reminder.childFamilyName}';
    } else {
      return '${User.user?.firstName} ${User.user?.familyName}';
    }
  }

  Future<void> _setInitialLocation(BuildContext context) async {
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
    _selectedPoint = Point(
      coordinates: Position(position.longitude, position.latitude),
    );

    if (_mapController != null) {
      _setUserAnnotation(_mapController!, _selectedPoint);
      _mapController!.flyTo(
        CameraOptions(center: _selectedPoint, zoom: 13.0),
        MapAnimationOptions(duration: 1500),
      );
      if(_reminder.bookAfter!.compareTo(DateTime.now()) <= 0) {
        _reminder.bookAfter = DateTime.now().add(const Duration(days: 1));
      }
      final controller = Provider.of<AppointmentController>(context, listen: false);
      controller.getAvailableCentersAutomatically(_reminder.vaccineId!, _reminder.bookAfter!, _selectedPoint).then((center) {
        if(controller.centersWithDistance.isNotEmpty) {
          _selectedCenter = controller.centersWithDistance[0]['center'];
          _setCenterAnnotation(_mapController!, _selectedCenter!);
        }
      });
    }
  }

  void _setUserAnnotation(MapboxMap mapController, Point point) async {
    // Load the image from assets
    final ByteData bytes = await rootBundle.load(
      'assets/icons/user_position_icon.png',
    );
    final Uint8List imageData = bytes.buffer.asUint8List();
    _pointAnnotationManager.deleteAll();
    _pointAnnotationManager.create(
      PointAnnotationOptions(
        geometry: point,
        image: imageData,
        iconSize: 0.25,
      ),
    );
  }

  Future<void> _setCenterAnnotation(MapboxMap mapboxMap, RecommendationResult center) async {
    // Load the image from assets
    final ByteData bytes = await rootBundle.load(
      'assets/icons/hospital_location_icon.png',
    );
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Create a PointAnnotationOptions
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(center.longitude!, center.latitude!),
      ), // Example coordinates
      image: imageData,
      iconSize: 0.25,
    );

    // Add the annotation to the map
    _centerAnnotationManager.deleteAll();
    _centerAnnotationManager.create(pointAnnotationOptions);
    _findRoute();
  }
  
  Future<void> _findRoute() async {
    print('Finding route...');
    // Build Mapbox Directions API URL
    final accessToken =
        'pk.eyJ1IjoibW91bmlyYmFkbGlzMiIsImEiOiJjbTl6emg5YjgwaGRyMmxzZng1cTkxa256In0.FCAWFO7Iqz5t4u2dGqSDwA'; // Replace with real token
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${_selectedPoint.coordinates.lng},${_selectedPoint.coordinates.lat};${_selectedCenter!.longitude},${_selectedCenter!.latitude}?geometries=geojson&access_token=$accessToken';

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(url);
      final data = response.data;

      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      List<Map<String, double>> points = [];
      for (var coord in coordinates) {
        double lng = (coord[0] as num).toDouble();
        double lat = (coord[1] as num).toDouble();
        points.add({'lng': lng, 'lat': lat});
      }
      print('Route found: $points');
      setState(() {
        _routePoints = points;
      });
      _addRouteLineToMap(_routePoints);
    } on DioException catch (e) {
      print('Error fetching route: ${e.response?.data}');
    }
  }
  
  void _addRouteLineToMap(List<Map<String, double>> points) async {
    print('Adding route to map...');
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
      if (await _mapController!.style.styleLayerExists(layerId)) {
        await _mapController!.style.removeStyleLayer(layerId);
      }

      // Check if source exists and remove it
      if (await _mapController!.style.styleSourceExists(sourceId)) {
        await _mapController!.style.removeStyleSource(sourceId);
      }

      // Add GeoJSON source
      String sourceJson = jsonEncode({'type': 'geojson', 'data': geoJson});
      await _mapController!.style.addStyleSource(sourceId, sourceJson);

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
      await _mapController!.style.addStyleLayer(layerJson, null);
    } catch (e) {
      print('Error adding route to map: $e');
    }
  }

  void _onMapTap(MapContentGestureContext coord) async {
    if (_mapController != null) {
      final point = Point(
        coordinates: Position(
          coord.point.coordinates.lng,
          coord.point.coordinates.lat,
        ),
      );
      setState(() {
        _selectedPoint = point;
      });
      _mapController!.flyTo(
        CameraOptions(center: _selectedPoint, zoom: 13.0),
        MapAnimationOptions(duration: 1000),
      );
    }
    _setUserAnnotation(_mapController!, _selectedPoint);
    if(_reminder.bookAfter!.compareTo(DateTime.now()) <= 0) {
      _reminder.bookAfter = DateTime.now().add(const Duration(days: 1));
    }
    final controller = Provider.of<AppointmentController>(context, listen: false);
    controller.getAvailableCentersAutomatically(_reminder.vaccineId!, _reminder.bookAfter!, _selectedPoint).then((center) {
      if(controller.centersWithDistance.isNotEmpty) {
        _selectedCenter = controller.centersWithDistance[0]['center'];
        _setCenterAnnotation(_mapController!, _selectedCenter!);
      }
    });
  }
  String _calculateDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(1)} ${AppLocalizations.of(context)!.m}';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}';
    }
  }
  
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() async {
    final appointmentController = Provider.of<AppointmentController>(context, listen: false);
  
    setState(() {
      _isLoading = true;
     });
  
    try {
      await appointmentController.bookAppointment(_reminder.childId!, _reminder.vaccineId!, _reminder.bookAfter!, _selectedCenter!.centerId, context);
    
    if(mounted) {
      _showSnackBar(AppLocalizations.of(context)!.appointment_booked_successfully);
      Navigator.pushReplacementNamed(context, '/main');
    }
  } catch (e) {
    if(mounted) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  } finally {
    if(mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
}