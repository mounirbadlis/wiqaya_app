import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/controllers/vaccine_controller.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

enum UserType {parent, child}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String _selectedUserType = 'parent';
  MapboxMap? _mapController;
  Vaccine? _selectedVaccine;
  VaccinationCenter? _selectedCenter;
  DateTime? _selectedDate;
  String? _concernedId;

  List<Map<String, double>> _routePoints = [];
  Point _selectedPoint = Point(coordinates: Position(10.6328, 36.8902));
  late final PointAnnotationManager pointAnnotationManager;
  late final PointAnnotationManager centerAnnotationManager;
  CameraOptions initialCamera = CameraOptions(
    center: Point(coordinates: Position(10.6328, 36.8902)),
    zoom: 7.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VaccineController>(context, listen: false).getVaccines();
      Provider.of<ChildrenController>(context, listen: false).getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final controller = Provider.of<AppointmentController>(
            context,
            listen: false,
          );
          controller.availableCenters.clear();
          controller.availableDays.clear();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context)!.book_appointment,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.white),
          ),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 200.h,
                    child: MapWidget(
                      styleUri: MapboxStyles.MAPBOX_STREETS,
                      cameraOptions: initialCamera,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _setInitialLocation();
                      },
                      onLongTapListener: _onMapTap,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.pick_instructions,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Consumer3<
                    AppointmentController,
                    VaccineController,
                    ChildrenController
                  >(
                    builder: (
                      context,
                      appointmentController,
                      vaccineController,
                      childrenController,
                      _,
                    ) {
                      if (vaccineController.isLoading ||
                          childrenController.isLoading) {
                        return Center(child: CustomCircularIndicator());
                      } else if (vaccineController.hasError ||
                          childrenController.hasError) {
                        return ErrorRetryWidget(
                          message: AppLocalizations.of(context)!.error_server,
                          onRetry: () {
                            vaccineController.getVaccines();
                          },
                        );
                      } else {
                        return Column(
                          children: [
                            _buildLabel(AppLocalizations.of(context)!.concerned),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(AppLocalizations.of(context)!.for_me),
                                    value: 'parent',
                                    groupValue: _selectedUserType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUserType = value!;
                                        _concernedId = User.user?.id;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(
                                      AppLocalizations.of(context)!.my_children,
                                    ),
                                    value: 'child',
                                    groupValue: _selectedUserType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUserType = value!;
                                        _concernedId = childrenController.children.first.id;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedUserType == 'child')
                              _buildLabel(AppLocalizations.of(context)!.child),
                            if (_selectedUserType == 'child')
                              DropdownButtonFormField<String?>(
                                value: _concernedId,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                    horizontal: 12.w,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _concernedId = value;
                                  });
                                },
                                items: childrenController.children.map((child) {
                                  return DropdownMenuItem(
                                    value: child.id,
                                    child: Text('${child.firstName} ${child.familyName}'),
                                  );
                                }).toList(),
                              ),
                              _buildLabel(AppLocalizations.of(context)!.vaccine),
                            DropdownButtonFormField<Vaccine?>(
                              value: _selectedVaccine,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                  horizontal: 12.w,
                                ),
                              ),
                              hint: Text(
                                AppLocalizations.of(context)!.select_vaccine,
                              ),
                              onChanged: (value) {
                                _selectedVaccine = value;
                                Provider.of<AppointmentController>(
                                  context,
                                  listen: false,
                                ).getAvailableDaysForVaccine(
                                  _selectedVaccine!.id,
                                );
                              },
                              items:
                                  vaccineController.vaccines.map((vaccine) {
                                    return DropdownMenuItem(
                                      value: vaccine,
                                      child: Text(vaccine.name),
                                    );
                                  }).toList(),
                            ),
                            SizedBox(height: 10.h),
                            _buildLabel(
                              AppLocalizations.of(context)!.available_dates,
                            ),
                            if (_selectedVaccine != null)
                              _buildDates(appointmentController, context),
                            if (_selectedDate != null)
                              _buildCenter(appointmentController, context),
                            InkWell(
                              onTap: () {
                                if (_selectedVaccine != null &&
                                    _selectedDate != null &&
                                    _selectedPoint != null) {
                                  
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.book_appointment,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          //padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    pointAnnotationManager =
        await _mapController!.annotations.createPointAnnotationManager();
    centerAnnotationManager =
        await _mapController!.annotations.createPointAnnotationManager();

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
    if (_selectedDate != null) {
      Provider.of<AppointmentController>(context, listen: false)
          .getAvailableCentersForDay(
            _selectedVaccine!,
            _selectedDate!,
            _selectedPoint,
          )
          .then((center) {
            _selectedCenter =
                Provider.of<AppointmentController>(
                  context,
                  listen: false,
                ).centersWithDistance[0]['center'];
            _setCenterAnnotation(_mapController!, _selectedCenter!);
          });
    }
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
    pointAnnotationManager.deleteAll();
    pointAnnotationManager.create(pointAnnotationOptions);
  }

  Future<void> _setCenterAnnotation(
    MapboxMap mapboxMap,
    VaccinationCenter center,
  ) async {
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
    centerAnnotationManager.deleteAll();
    centerAnnotationManager.create(pointAnnotationOptions);
    _findRoute();
  }

  Widget _buildDates(
    AppointmentController appointmentController,
    BuildContext context,
  ) {
    if (appointmentController.isLoading) {
      return const Center(child: CustomCircularIndicator());
    } else if (appointmentController.hasError) {
      return ErrorRetryWidget(
        message: AppLocalizations.of(context)!.error_server,
        onRetry: () {
          appointmentController.getAvailableDaysForVaccine(
            _selectedVaccine!.id,
          );
        },
      );
    } else if (appointmentController.availableDays.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.no_data));
    } else {
      return Column(
        children: [
          DropdownButtonFormField<DateTime>(
            value: _selectedDate,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 12.w,
              ),
            ),
            hint: Text(AppLocalizations.of(context)!.select_date),
            onChanged: (value) {
              _selectedDate = value!;
              appointmentController
                  .getAvailableCentersForDay(
                    _selectedVaccine!,
                    _selectedDate!,
                    _selectedPoint,
                  )
                  .then((center) {
                    _selectedCenter =
                        appointmentController.centersWithDistance[0]['center'];
                    _setCenterAnnotation(_mapController!, _selectedCenter!);
                  });
            },
            items:
                appointmentController.availableDays.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(intl.DateFormat('yyyy/MM/dd').format(day)),
                  );
                }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildCenter(
    AppointmentController appointmentController,
    BuildContext context,
  ) {
    if (appointmentController.isAvailableCentersLoading) {
      return const Center(child: CustomCircularIndicator());
    } else if (appointmentController.isAvailableCentersError) {
      return ErrorRetryWidget(
        message: AppLocalizations.of(context)!.error_server,
        onRetry: () {
          appointmentController.getAvailableCentersForDay(
            _selectedVaccine!,
            _selectedDate!,
            _selectedPoint,
          );
        },
      );
    } else {
      return Column(
        children: [
          SizedBox(height: 10.h),
          _buildLabel(AppLocalizations.of(context)!.available_centers),
          Row(
            children: [
              Text(
                '${appointmentController.centersWithDistance[0]['center'].name} ${_calculateDistance(appointmentController.centersWithDistance[0]['distance'])}',
              ),
            ],
          ),
        ],
      );
    }
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

  String _calculateDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(1)} ${AppLocalizations.of(context)!.m}';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}';
    }
  }
}
