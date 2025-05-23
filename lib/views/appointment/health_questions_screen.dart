import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/reminder_controller.dart';
import 'package:wiqaya_app/models/reminder.dart';
import 'package:wiqaya_app/models/user.dart';

class HealthQuestionsScreen extends StatefulWidget {
  const HealthQuestionsScreen({super.key});

  @override
  State<HealthQuestionsScreen> createState() => _HealthQuestionsScreenState();
}

class _HealthQuestionsScreenState extends State<HealthQuestionsScreen> {

  List<Map<String, dynamic>> questions = [
    {'type': 1, 'value': false},
    {'type': 2, 'value': false},
  ];

  DateTime? endTreatmentDate;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final reminder = Provider.of<ReminderController>(context, listen: false).selectedReminder!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamed(context, '/notifications');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/reminders');
            },
          ),
          title: Text(AppLocalizations.of(context)!.book_appointment, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(loc.receiver, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                    subtitle: Text(_buildReceiverName(reminder)),
                  ),
                  ListTile(
                    title: Text(loc.vaccine, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                    subtitle: Text(reminder.vaccineName ?? ''),
                  ),
                  _buildVaccineCheckbox(questions[0], loc),
                  _buildVaccineCheckbox(questions[1], loc),
                  if (questions[1]['value'])
                    _buildDatePicker(endTreatmentDate, loc),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildReceiverName(Reminder reminder) {
    if(reminder.childId != null) {
      return '${reminder.childFirstName} ${reminder.childFamilyName}';
    } else {
      return '${User.user?.firstName} ${User.user?.familyName}';
    }
  }

  Widget _buildVaccineCheckbox(Map<String, dynamic> question, AppLocalizations loc) {
    return CheckboxListTile(
      title: Text(
        question['type'] == 1 ? loc.has_fever_question : loc.on_treatment_question, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(question['type'] == 1 ? loc.has_fever_hint : loc.on_treatment_hint, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),),
      value: question['value'] ?? false,
      onChanged: (bool? value) {
        setState(() {
          question['value'] = value ?? false;
        });
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      activeColor: Theme.of(context).secondaryHeaderColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildDatePicker(DateTime? date, AppLocalizations loc) {
    return ListTile(
      title: Text(loc.select_date),
      subtitle: Text(date?.toString() ?? ''),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != date) {
          setState(() {
            endTreatmentDate = picked;
          });
          }
        },
    );
  }
}