import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AskQuestionsManualDialog extends StatefulWidget {
  const AskQuestionsManualDialog({super.key});

  @override
  State<AskQuestionsManualDialog> createState() => _AskQuestionsManualDialogState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AskQuestionsManualDialog(),
    );
  }
}

class _AskQuestionsManualDialogState extends State<AskQuestionsManualDialog> {
  List<Map<String, dynamic>> questions = [
    {'type': 1, 'value': false, 'reason': ''},
    {'type': 2, 'value': false, 'reason': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      title: Text(loc.confirmation, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.make_sure, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
          _buildVaccineCheckbox(questions[0], loc),
          _buildVaccineCheckbox(questions[1], loc),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if(questions[1]['value']) {
              String reason = loc.treatment_selected_reason;
              Navigator.of(context).pop();
              _showSnackBar(context, reason);
            }
            else if (questions[0]['value']) {
              String reason = loc.fever_selected_reason;
              Navigator.of(context).pop();
              _showSnackBar(context, reason);
            } else {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/appointments/book');
            }
          },
          child: Text(loc.continue_, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(loc.cancel, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
        ),
      ],
    );
  }

  Widget _buildVaccineCheckbox(Map<String, dynamic> question, AppLocalizations loc) {
    return CheckboxListTile(
      title: Text(question['type'] == 1 ? loc.has_fever_question : loc.on_treatment_question, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
      value: question['value'] ?? false,
      onChanged: (bool? value) {
        setState(() {
          question['value'] = value ?? false;
          question['reason'] = question['type'] == 1 ? loc.has_fever_question : loc.on_treatment_question;
        });
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      activeColor: Theme.of(context).secondaryHeaderColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}