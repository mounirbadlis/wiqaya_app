import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/widgets/appointment/postponed_appointment_widget.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';

class PostponedAppointmentsScreen extends StatefulWidget{
  const PostponedAppointmentsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PosponedAppointmentsScreenState();

}

class _PosponedAppointmentsScreenState extends State<PostponedAppointmentsScreen>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentController>(context, listen: false).getPostponedVaccinations(User.user!.id);
    });
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamed(context, '/main');
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/main');
          },
        ),
        title: Text(AppLocalizations.of(context)!.postponed_appointments, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        padding: EdgeInsets.only(top: 10.w),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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
                          controller.getPostponedVaccinations(User.user!.id);
                        },
                      );
                    } else if (controller.postponedVaccinations.isEmpty) {
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
                        itemCount: controller.postponedVaccinations.length,
                        itemBuilder: (context, index) {
                          final postponedVaccination = controller.postponedVaccinations[index];
                          return PostponedAppointmentWidget(postponedAppointment: postponedVaccination);
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