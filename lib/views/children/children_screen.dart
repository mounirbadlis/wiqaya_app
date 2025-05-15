import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/widgets/children/child_widget.dart';
import 'package:wiqaya_app/widgets/shared/add_button.dart';
import 'package:wiqaya_app/widgets/shared/custom_circular_indicator.dart';
import 'package:wiqaya_app/widgets/shared/error_retry_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ChildrenController>(
        context,
        listen: false,
      );
      controller.getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).secondaryHeaderColor,
      onRefresh: () async {
        final controller = Provider.of<ChildrenController>(
          context,
          listen: false,
        );
        await controller.getChildren();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).secondaryHeaderColor,
              padding: EdgeInsets.only(top: 10.w),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  //borderRadius: BorderRadius.circular(20),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Consumer<ChildrenController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CustomCircularIndicator());
                    } else if (controller.hasError) {
                      return ErrorRetryWidget(
                        message: AppLocalizations.of(context)!.error_server,
                        onRetry: () {
                          final controller = Provider.of<ChildrenController>(
                            context,
                            listen: false,
                          );
                          controller.getChildren();
                        },
                      );
                    } else if (controller.children.isEmpty) {
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
                        itemCount: controller.children.length,
                        itemBuilder: (context, index) {
                          final child = controller.children[index];
                          return ChildWidget(child: child);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: Center(
                child: AddButton(
                  title: AppLocalizations.of(context)!.add_child,
                  onTap: () {
                    Navigator.pushNamed(context, '/children/add');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
