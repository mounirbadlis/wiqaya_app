import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/vaccine_controller.dart';
import 'package:wiqaya_app/widgets/drawer/drawer.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/widgets/vaccine/vaccine_widget.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<VaccineController>(context, listen: false);
      controller.getVaccines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).secondaryHeaderColor,
      onRefresh: () async {
        final controller = Provider.of<VaccineController>(
          context,
          listen: false,
        );
        await controller.getVaccines();
      },
      child: Scaffold(
        drawer: const DrawerWidget(),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            AppLocalizations.of(context)!.vaccines,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.white),
          ),
        ),
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
            child: Consumer<VaccineController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.hasError) {
                  return ErrorRetryWidget(
                    message: AppLocalizations.of(context)!.error_server,
                    onRetry: () {
                      final controller = Provider.of<VaccineController>(
                        context,
                        listen: false,
                      );
                      controller.getVaccines();
                    },
                  );
                } else if (controller.vaccines.isEmpty) {
                  return const Center(child: Text('No vaccines found'));
                } else {
                  return ListView.builder(
                    itemCount: controller.vaccines.length,
                    itemBuilder: (context, index) {
                      final vaccine = controller.vaccines[index];
                      return VaccineWidget(vaccine: vaccine);
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
