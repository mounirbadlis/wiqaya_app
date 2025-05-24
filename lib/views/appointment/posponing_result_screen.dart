import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/postponed_vaccination.dart';
import 'package:wiqaya_app/models/user.dart';

class PosponingResultScreen extends StatelessWidget {
  PosponingResultScreen({super.key});
  PostponedVaccination? postponedVaccination;
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    postponedVaccination = Provider.of<AppointmentController>(context, listen: false).postponedVaccination;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          automaticallyImplyLeading: false,
          title: Center(child: Text(loc.postponing_success, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white))),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
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
                Center(child: Text(loc.postponing_message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium)),
                SizedBox(height: 10.h),
                Center(child: Text(intl.DateFormat('yyyy-MM-dd').format(postponedVaccination!.retryDate!), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall)),
                SizedBox(height: 20.h),
                ListTile(
                  title: Text(loc.receiver, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                  subtitle: Text(_buildReceiverName(), style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black),),
                ),
                ListTile(
                  title: Text(loc.vaccine, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                  subtitle: Text(postponedVaccination!.vaccineName ?? '', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black),),
                ),
                ListTile(
                  title: Text(loc.reason, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                  subtitle: Text(postponedVaccination!.reason == loc.fever ? loc.fever : loc.treatment, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black),),
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(loc.ok, style: TextStyle(fontSize: 16.sp,color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildReceiverName() {
    if(postponedVaccination!.childFirstName != null) {
      return '${postponedVaccination!.childFirstName} ${postponedVaccination!.childFamilyName}';
    } else {
      return '${User.user?.firstName} ${User.user?.familyName}';
    }
  }
}