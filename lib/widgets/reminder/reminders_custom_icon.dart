import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/reminder_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RemindersCustomIcon extends StatelessWidget {
  const RemindersCustomIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/reminders');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Stack(
          children: [
            Icon(Iconsax.notification, size: 30.sp),
            Positioned(
              right: 0,
              top: 0,
              child: Consumer<ReminderController>(
                builder: (context, reminderController, child) {
                  int unseenCount = reminderController.unseenCount;
                  if (unseenCount == 0) return SizedBox.shrink();
                  return Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Center(
                      child: Text('$unseenCount', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}