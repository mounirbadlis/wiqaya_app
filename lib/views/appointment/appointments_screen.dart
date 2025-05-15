import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/widgets/appointment/appointment_widget.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AppointmentController>(
        context,
        listen: false,
      );
      controller.getAppointments(User.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).secondaryHeaderColor,
      onRefresh: () async {
        final controller = Provider.of<AppointmentController>(
          context,
          listen: false,
        );
        await controller.getAppointments(User.user!.id);
      },
      child: Scaffold(
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              //borderRadius: BorderRadius.circular(20),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Consumer<AppointmentController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CustomCircularIndicator());
                } else if (controller.hasError) {
                  return ErrorRetryWidget(
                    message: AppLocalizations.of(context)!.error_server,
                    onRetry: () {
                      final controller = Provider.of<AppointmentController>(
                        context,
                        listen: false,
                      );
                      controller.getAppointments(User.user!.id);
                    },
                  );
                } else if (controller.appointments.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_data,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: controller.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = controller.appointments[index];
                      return AppointmentWidget(appointment: appointment);
                    },
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
