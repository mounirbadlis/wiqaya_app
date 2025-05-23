import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/reminder_controller.dart';
import 'package:wiqaya_app/widgets/reminder/reminder_widget.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ReminderController>(context, listen: false);
      controller.getReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).secondaryHeaderColor,
      onRefresh: () async {
        final controller = Provider.of<ReminderController>(context, listen: false);
        await controller.getReminders();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          title: Text(AppLocalizations.of(context)!.notifications,style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/main');
            },
          ),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              //borderRadius: BorderRadius.circular(20),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Consumer<ReminderController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CustomCircularIndicator());
                } else if (controller.hasError) {
                  return ErrorRetryWidget(
                    message: AppLocalizations.of(context)!.error_server,
                    onRetry: () {
                      final controller = Provider.of<ReminderController>(context, listen: false);
                      controller.getReminders();
                    },
                  );
                } else if (controller.reminders.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_data,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.mark_all_as_read,style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).secondaryHeaderColor),)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = controller.reminders[index];
                            return ReminderWidget(reminder: reminder, index: index);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
