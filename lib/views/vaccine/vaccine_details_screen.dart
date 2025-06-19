import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/vaccine_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:hugeicons/hugeicons.dart';

class VaccineDetailsScreen extends StatelessWidget {
  VaccineDetailsScreen({super.key});
  String requredAges = '';
  Vaccine? vaccine;
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VaccineController>(context);
    vaccine = controller.selectedVaccine;
    _setRequiredAges(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${vaccine!.name} Vaccine', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
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
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  vaccine!.pictureUrl!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200.h,
                      alignment: Alignment.center,
                      color: Colors.grey[500],
                      child: Icon(HugeIcons.strokeRoundedImageNotFound01, size: 60.w),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(5.w),
                width: double.infinity,
                child: Text(
                  vaccine!.description,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                tileColor: Theme.of(context).primaryColor.withAlpha(255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  AppLocalizations.of(context)!.required_ages,
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                subtitle: Text(
                  requredAges,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                tileColor: Theme.of(context).primaryColor.withAlpha(255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  AppLocalizations.of(context)!.side_effects,
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                subtitle: Text(
                  '- ${vaccine!.sideEffects!.join('\n- ')}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setRequiredAges(BuildContext context) {
    if (vaccine?.requiredAges?.isEmpty ?? true) {
      requredAges = AppLocalizations.of(context)!.no_specific_ages;
      return;
    }
    if (vaccine?.requiredAges?.length == 1) {
      if (vaccine?.requiredAges?[0] == 0) {
        requredAges = AppLocalizations.of(context)!.birth;
      } else {
        requredAges =
            '${vaccine?.requiredAges?[0]} ${AppLocalizations.of(context)!.month}';
      }
    } else {
      requredAges =
          '${vaccine?.requiredAges!.join(', ')} ${AppLocalizations.of(context)!.months}';
    }
  }
}
