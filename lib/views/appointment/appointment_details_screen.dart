import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/models/appointment.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  AppointmentDetailsScreen({super.key});
  Appointment? appointment;
  CameraOptions camera = CameraOptions(
    //center: Point(coordinates: Position(-98.0, 39.5)),
    zoom: 2,
    bearing: 0,
    pitch: 0,
  );
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppointmentController>(context);
    appointment = controller.selectedAppointment;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
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
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 200.h,
                child: MapWidget(
                  styleUri: MapboxStyles.SATELLITE_STREETS,
                  cameraOptions: camera,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
