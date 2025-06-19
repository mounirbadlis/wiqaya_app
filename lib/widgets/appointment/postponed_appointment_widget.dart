import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/postponed_vaccination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostponedAppointmentWidget extends StatelessWidget {
  const PostponedAppointmentWidget({Key? key, required this.postponedAppointment});

  final PostponedVaccination postponedAppointment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final controller = Provider.of<AppointmentController>(context, listen: false);
        controller.selectedPostponedVaccination = postponedAppointment;
        Navigator.pushNamed(context, '/appointments/postponed/details');
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
                  postponedAppointment.vaccineName ?? AppLocalizations.of(context)!.unknown,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 1.h),
                Text(
                  _setFor(context),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 1.h),
                Text(
                  intl.DateFormat('yyyy/MM/dd').format(postponedAppointment.retryDate ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  String _setFor(BuildContext context) {
    if (postponedAppointment.childFirstName == null) {
      return AppLocalizations.of(context)!.for_me;
    } else {
      // Manually concatenate 'For: ' with the names to avoid using the reserved keyword
      return '${AppLocalizations.of(context)!.for_child}: ${postponedAppointment.childFirstName} ${postponedAppointment.childFamilyName}';
    }
  }
}