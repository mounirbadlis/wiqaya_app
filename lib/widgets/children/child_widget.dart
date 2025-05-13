import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/models/child.dart';

class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key, required this.child});
  final Child child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final childController = Provider.of<ChildrenController>(context, listen: false);
        childController.selectedChild = child;
        Navigator.pushNamed(context, '/children/child_history');
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.firstName,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${DateTime.now().year - child.birthDate.year} years old',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  child.gender == 1 ? AppLocalizations.of(context)!.male : AppLocalizations.of(context)!.female,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 4.h),
                Text(
                  child.bloodType,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}