import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/vaccine_controller.dart';

class VaccineWidget extends StatelessWidget {
  VaccineWidget({super.key, required this.vaccine});
  final Vaccine vaccine;
  String requredAges = '';
  @override
  Widget build(BuildContext context) {
    _setRequiredAges(context);
    return InkWell(
      onTap: () {
        final controller = Provider.of<VaccineController>(context, listen: false);
        controller.selectedVaccine = vaccine;
        Navigator.pushNamed(context, '/vaccines/vaccine_details');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.w),
        padding: EdgeInsets.all(10.w),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vaccine.pictureUrl!,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                    //Placeholder(fallbackHeight: 60.w, fallbackWidth: 60.w)
                        Icon(HugeIcons.strokeRoundedImageNotFound01, size: 60.w),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(requredAges, style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setRequiredAges(BuildContext context) {
    if (vaccine.requiredAges?.isEmpty ?? true) {
      requredAges = '';
      return;
    } else if (vaccine.requiredAges?.length == 1) {
      if (vaccine.requiredAges?[0] == 0) {
        requredAges = AppLocalizations.of(context)!.birth;
      } else {
        requredAges = '${vaccine.requiredAges?[0]} ${AppLocalizations.of(context)!.month}';
      }
    } else {
      requredAges = '${vaccine.requiredAges!.join(', ')} ${AppLocalizations.of(context)!.months}';
    }
  }
}
