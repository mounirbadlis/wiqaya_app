import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
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
  late Reminder reminder;
  DateTime? endTreatmentDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final reminderController = Provider.of<ReminderController>(context, listen: false);
    reminder = reminderController.selectedReminder!;
    final baseDate = reminder.bookAfter ?? DateTime.now().add(const Duration(days: 1));
    endTreatmentDate = baseDate.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(days: 1))
        : baseDate;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamed(context, '/reminders');
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
          title: Text(
            AppLocalizations.of(context)!.book_appointment,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
          ),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.receiver, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  subtitle: Text(_buildReceiverName()),
                ),
                ListTile(
                  title: Text(loc.vaccine, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  subtitle: Text(reminder.vaccineName ?? ''),
                ),
                _buildVaccineCheckbox(questions[0], loc),
                _buildVaccineCheckbox(questions[1], loc),
                if (questions[1]['value']) _buildDatePicker(loc),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHealthQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(strokeWidth: 1.sp, color: Colors.white)
                        : Text(
                            questions[0]['value'] || questions[1]['value']
                                ? loc.postpone
                                : loc.continue_,
                            style: TextStyle(fontSize: 16.sp, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildReceiverName() {
    if (reminder.childId != null) {
      return '${reminder.childFirstName} ${reminder.childFamilyName}';
    } else {
      return '${User.user?.firstName} ${User.user?.familyName}';
    }
  }

  Widget _buildVaccineCheckbox(Map<String, dynamic> question, AppLocalizations loc) {
    return CheckboxListTile(
      title: Text(
        question['type'] == 1 ? loc.has_fever_question : loc.on_treatment_question,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        question['type'] == 1 ? loc.has_fever_hint : loc.on_treatment_hint,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
      ),
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

  Widget _buildDatePicker(AppLocalizations loc) {
    return ListTile(
      title: Text(loc.select_date),
      subtitle: Text(intl.DateFormat('yyyy/MM/dd').format(endTreatmentDate!)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: endTreatmentDate!,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime(3000),
        );
        if (picked != null && picked != endTreatmentDate) {
          setState(() {
            endTreatmentDate = picked;
            print('endTreatmentDate: $endTreatmentDate');
          });
        }
      },
    );
  }

  void _saveHealthQuestions() async {
    DateTime? retryDate;
    int reason;
    int type;
    final appointmentController = Provider.of<AppointmentController>(context, listen: false);
    try {
      if (questions[0]['value'] || questions[1]['value']) {
        setState(() {
          _isLoading = true;
        });

        if (questions[1]['value']) {
          reason = 2;
          retryDate = endTreatmentDate!;
        } else {
          reason = 1;
          retryDate = DateTime.now().add(const Duration(days: 2));
        }
        if (reminder.childId == null) {
          type = 1;
        } else {
          type = 2;
        }
        await appointmentController.postponeAppointment(
          reminder.childId ?? User.user!.id,
          reminder.vaccineId!,
          reason,
          retryDate,
          reminder.childFirstName,
          reminder.childFamilyName,
          reminder.vaccineName,
          type,
          context,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamed(context, '/appointments/health_questions/result');
        }
      } else {
        Navigator.pushNamed(context, '/appointments/health_questions/nearest');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
