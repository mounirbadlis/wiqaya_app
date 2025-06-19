import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/center_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';
import 'package:geolocator/geolocator.dart' as geo;

class CentersScreen extends StatefulWidget {
  const CentersScreen({Key? key}) : super(key: key);
  
  @override
  State<CentersScreen> createState() {
    return _CentersScreenState();
  }
}

class _CentersScreenState extends State<CentersScreen> {
  late MapboxMap _mapController;
  bool _isLoading = false;
  bool _mapReady = false;
  PointAnnotationManager? _pointAnnotationManager;
  List<VaccinationCenter> _centers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCenters();
    });
  }

    Future<geo.Position?> _getUserLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled');
      return null;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        _showSnackBar('Location permission denied');
        return null;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      _showSnackBar('Location permission permanently denied');
      return null;
    }
    final position = await geo.Geolocator.getCurrentPosition();
    return position;
  }
  Future<void> _loadCenters() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<CenterController>(context, listen: false).getCenters();
      final controller = Provider.of<CenterController>(context, listen: false);
      _centers = controller.centers ?? [];
      
      if (_mapReady && _centers.isNotEmpty) {
        await _addCenterAnnotations();
      }
    } catch (e) {
      _showSnackBar('Error loading centers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // User location functionality removed as distance calculation is not needed

  Future<void> _addCenterAnnotations() async {
    if (_pointAnnotationManager == null || _centers.isEmpty) return;

    try {
      final ByteData bytes = await rootBundle.load('assets/icons/hospital_location_icon.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      for (var center in _centers) {
        if (center.latitude != null && center.longitude != null) {
          PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(center.longitude!, center.latitude!),
            ),
            image: imageData,
            iconSize: 0.25,
            textField: center.name ?? 'Vaccination Center',
          );

          await _pointAnnotationManager!.create(pointAnnotationOptions);
        }
      }
    } catch (e) {
      print('Error adding center annotations: $e');
    }
  }

  void _showCenterDialog(VaccinationCenter center) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedHospital01,
                color: Theme.of(context).secondaryHeaderColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  center.name ?? 'Vaccination Center',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (center.providerFirstName != null && center.providerFamilyName != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.person_rounded,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  title: Text(
                    '${AppLocalizations.of(context)!.provider_name}: ',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${center.providerFirstName} ${center.providerFamilyName}',
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                ),
              ],
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(
              //     HugeIcons.strokeRoundedLocation01,
              //     color: Theme.of(context).secondaryHeaderColor,
              //   ),
              //   title: Text(
              //     '${AppLocalizations.of(context)!.location ?? 'Location'}: ',
              //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              //   subtitle: Text(
              //     '${center.latitude?.toStringAsFixed(4)}, ${center.longitude?.toStringAsFixed(4)}',
              //     style: Theme.of(context).textTheme.bodyMedium!,
              //   ),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToCenter(center);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.navigate),
            ),
          ],
        );
      },
    );
  }

  // Distance calculation functionality removed

  void _navigateToCenter(VaccinationCenter center) {
    if (center.latitude != null && center.longitude != null) {
      // Move camera to center the selected center
      CameraOptions camera = CameraOptions(
        center: Point(coordinates: Position(center.longitude!, center.latitude!)),
        zoom: 16.0,
      );
      
      _mapController.flyTo(camera, null);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.centers,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCenters,
          ),
        ],
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
            children: [
              if (_isLoading) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        AppLocalizations.of(context)!.loading_centers,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Consumer<CenterController>(
                    builder: (context, controller, child) {
                      // Set default camera position
                      CameraOptions camera = CameraOptions(
                        center: Point(coordinates: Position(0.0, 0.0)), // Default center
                        zoom: 8.0,
                      );

                      return MapWidget(
                        styleUri: MapboxStyles.MAPBOX_STREETS,
                        cameraOptions: camera,
                        onMapCreated: (mapController) async {
                          _mapController = mapController;
                          _pointAnnotationManager = await _mapController.annotations.createPointAnnotationManager();
                          _mapReady = true;

                          // Navigate to user's current location
                          final position = await _getUserLocation();
                          if (position != null && mounted) {
                            CameraOptions camera = CameraOptions(
                              center: Point(coordinates: Position(position.longitude, position.latitude)),
                              zoom: 14.0,
                            );
                            await _mapController.flyTo(camera, null);
                          }

                          if (_centers.isNotEmpty) {
                            await _addCenterAnnotations();
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCenters,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
