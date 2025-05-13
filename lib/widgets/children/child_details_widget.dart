import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:wiqaya_app/models/child.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChildDetailsWidget extends StatelessWidget {
  const ChildDetailsWidget({Key? key, required this.child});
  final Child child;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.first_name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
              ),
              subtitle: Text(
                child.firstName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
            ),
            SizedBox(height: 16.h),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.family_name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
              ),
              subtitle: Text(
                child.familyName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Iconsax.cake),
              title: Text(
                intl.DateFormat('yyyy/MM/dd').format(child.birthDate),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(
                child.gender == 1 ? Icons.male : Icons.female,
                color: child.gender == 1 ? Colors.blue : Colors.pink,
              ),
              title: Text(
                child.gender == 1 ? 'Male' : 'Female',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Iconsax.drop, color: Colors.red),
              title: Text(
                child.bloodType,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
