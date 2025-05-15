import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:wiqaya_app/models/historical_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

class RecordDialog extends StatelessWidget {
  const RecordDialog({super.key, required this.record});

  final HistoricalRecord record;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.record_details,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              Iconsax.calendar,
              color: Colors.indigo,
            ),
            title: Text(
              intl.DateFormat('yyyy/MM/dd').format(record.takedAt),
            ),
          ),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedHospitalLocation,
              color: Colors.teal,
            ),
            title: Text(
              record.centerName ?? AppLocalizations.of(context)!.unknown,
            ),
          ),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedDoctor01,
              color: Colors.deepPurple,
            ),
            title: Text(
              '${record.providerName ?? AppLocalizations.of(context)!.unknown} ${record.providerFamily ?? ''}',
            ),
          ),
        ],
      ),
    );
  }
}
