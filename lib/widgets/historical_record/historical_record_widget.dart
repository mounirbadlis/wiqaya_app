import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wiqaya_app/models/historical_record.dart';
import 'package:wiqaya_app/widgets/dialogs/record_dialog.dart';

class HistoricalRecordWidget extends StatelessWidget {

  final HistoricalRecord record;

  const HistoricalRecordWidget({super.key, required this.record});
  @override
  Widget build(BuildContext context) {
  final dateFormat = intl.DateFormat('yyyy/MM/dd');
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => RecordDialog(record: record),
        );
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
                Text(record.vaccines, style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 16.sp)),
                Text(dateFormat.format(record.takedAt), style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16.sp)),
              ],
            ),
            Icon(Iconsax.tick_circle, size: 40.w, color: Colors.green,),
          ],
        ),
      ),
    );
  }
}