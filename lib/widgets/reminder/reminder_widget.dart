import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wiqaya_app/controllers/reminder_controller.dart';
import 'package:wiqaya_app/models/reminder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ReminderWidget extends StatelessWidget {
  ReminderWidget({super.key, required this.reminder, this.index = 2});
  
  final Reminder reminder;
  int? index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (reminder.type == 1 && reminder.isSolved == false) {
          Provider.of<ReminderController>(context, listen: false).selectedReminder = reminder;
          Navigator.pushNamed(context, '/appointments/health_questions');
        }
      },
      child: Container(
        height: 90.h,
        width: double.infinity,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
        color: reminder.seen ? Theme.of(context).primaryColor : Color.fromRGBO(240,246,254, 1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, width: 0.1.w,
          ),
        ),
        ),
        child: Column(
          children: [
            Container(alignment: Alignment.centerLeft, child: Text(reminder.title, textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),)),
            Text(reminder.message, textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),),
            Container(alignment: Alignment.centerLeft, child: Text(_calculateTime(context), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600], fontSize: 12.sp),)),
          ],
        ),
      ),
    );
  }

  String _calculateTime(BuildContext context) {
    DateTime createdAt = reminder.createdAt;
    DateTime now = DateTime.now();
    Duration diff = now.difference(createdAt);
    
    if (diff.inDays > 0) {
      return diff.inDays.toString() + ' ' + AppLocalizations.of(context)!.days_ago;
    } else if (diff.inHours > 0) {
      return diff.inHours.toString() + ' ' + AppLocalizations.of(context)!.hours_ago;
    } else if (diff.inMinutes > 0) {
      return diff.inMinutes.toString() + ' ' + AppLocalizations.of(context)!.minutes_ago;
    } else {
      return diff.inSeconds.toString() + ' ' + AppLocalizations.of(context)!.seconds_ago;
    }
  }
}