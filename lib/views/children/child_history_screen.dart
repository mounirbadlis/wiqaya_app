import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wiqaya_app/models/child.dart';
import 'package:wiqaya_app/models/historical_record.dart';
import 'package:wiqaya_app/views/histrical_record/histrical_records.dart';
import 'package:wiqaya_app/widgets/children/child_details_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChildHistoryScreen extends StatelessWidget {
  final Child child;

  const ChildHistoryScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // two tabs: Data & History
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('${child.firstName} ${child.familyName}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
          bottom: TabBar(
            indicatorColor: Theme.of(context).secondaryHeaderColor,
            labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).secondaryHeaderColor),
            unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Theme.of(context).primaryColor,
            ),
            tabs: [
              Tab(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(AppLocalizations.of(context)!.personal_info),
              )),
              Tab(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(AppLocalizations.of(context)!.record),
              )),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).primaryColor,
          child: TabBarView(
            children: [
              // Tab 1: Child Data
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: ChildDetailsWidget(child: child),
              ),
          
              // Tab 2: History List
              HistoricalRecords(id: child.id, isParent: false),
            ],
          ),
        ),
      ),
    );
  }
}
