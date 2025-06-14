import 'package:intl/intl.dart' as intl;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentWidget extends StatelessWidget {
  const AppointmentWidget({Key? key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final controller = Provider.of<AppointmentController>(context, listen: false);
        controller.selectedAppointment = appointment;
        Navigator.pushNamed(context, '/appointments/details');
      },
      child: Container(
          margin: EdgeInsets.only(bottom: 10.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.vaccine?.name ?? AppLocalizations.of(context)!.unknown,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 1.h),
                Text(
                  _setFor(context),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 1.h),
                Text(
                  intl.DateFormat('yyyy/MM/dd').format(appointment.schedule?.date ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            Spacer(),
            _buildStatus(context),
          ],
        ),
      ),
    );
  }

  String _setFor(BuildContext context) {
    if (appointment.firstName == null) {
      return AppLocalizations.of(context)!.for_me;
    } else {
      // Manually concatenate 'For: ' with the names to avoid using the reserved keyword
      return '${AppLocalizations.of(context)!.for_child}: ${appointment.firstName} ${appointment.familyName}';
    }
  }

  Widget _buildStatus(BuildContext context) {
    switch (appointment.status) {
      case 1:
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue,
          ),
          child: Text(AppLocalizations.of(context)!.confirmed, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      case 2:
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.green,
          ),
          child: Text(AppLocalizations.of(context)!.completed, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      case 3:
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
          ),
          child: Text(AppLocalizations.of(context)!.cancelled, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      default:
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue,
          ),
          child: Text(AppLocalizations.of(context)!.confirmed, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        );
    }
  } 
}