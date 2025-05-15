import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/historical_record_controller.dart';
import 'package:wiqaya_app/widgets/historical_record/historical_record_widget.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoricalRecords extends StatefulWidget {
  HistoricalRecords({super.key, required this.id, this.isParent = true});

  final String? id;
  bool isParent = true;

  @override
  State<StatefulWidget> createState() => _HistoricalRecordsState();
}

class _HistoricalRecordsState extends State<HistoricalRecords> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HistoricalRecordController>(
        context,
        listen: false,
      );
      controller.getHistoricalRecords(widget.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).secondaryHeaderColor,
      onRefresh: () async {
        final controller = Provider.of<HistoricalRecordController>(
          context,
          listen: false,
        );
        await controller.getHistoricalRecords(widget.id!);
      },
      child: Container(
        color: widget.isParent ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,
        padding: widget.isParent ? EdgeInsets.only(top: 10.w) : EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Consumer<HistoricalRecordController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CustomCircularIndicator());
              } else if (controller.hasError) {
                return ErrorRetryWidget(
                  message: AppLocalizations.of(context)!.error_server,
                  onRetry: () {
                    final controller = Provider.of<HistoricalRecordController>(context, listen: false);
                    controller.getHistoricalRecords(widget.id!);
                  },
                );
              } else if (controller.historicalRecords.isEmpty) {
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
                  itemCount: controller.historicalRecords.length,
                  itemBuilder: (context, index) {
                    final record = controller.historicalRecords[index];
                    return HistoricalRecordWidget(record: record);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
