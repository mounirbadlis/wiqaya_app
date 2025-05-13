import 'package:flutter/material.dart';
import 'package:wiqaya_app/models/historical_record.dart';

class RecordDialog extends StatelessWidget {
  const RecordDialog({super.key, required this.record});
  final HistoricalRecord record;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(record.vaccines),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(record.centerName!),
          Text(record.takedAt!.toIso8601String()),
        ],
      ),
    );
  }
}
  