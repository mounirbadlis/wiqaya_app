import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/views/appointment/appointments_screen.dart';
import 'package:wiqaya_app/views/children/children_screen.dart';
import 'package:wiqaya_app/views/histrical_record/histrical_records.dart';
import 'package:wiqaya_app/widgets/drawer/drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key, this.selectedIndex = 0});
  int selectedIndex;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final List<Widget> _pages = [
    Center(child: Text('Home Page')),
    const AppointmentsScreen(),
    const ChildrenScreen(),
    HistoricalRecords(id: User.user!.id),
  ];

  void _onItemTapped(int index) {
    setState(() {
    widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
      },
      child: Scaffold(
        drawer: DrawerWidget(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(_getAppBarTitle(), style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white)),
        ),
        body: _pages[widget.selectedIndex],
        bottomNavigationBar: Container(
          color: Colors.white,
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).secondaryHeaderColor,
            selectedFontSize: 15.sp,
            unselectedFontSize: 12.sp,
            currentIndex: widget.selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home_1_copy),
                activeIcon: Icon(Iconsax.home_1),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.calendar_copy),
                activeIcon: Icon(Iconsax.calendar),
                label: AppLocalizations.of(context)!.appointments,
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.people_copy),
                activeIcon: Icon(Iconsax.people),
                label: AppLocalizations.of(context)!.my_children,
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.note_text_copy),
                activeIcon: Icon(Iconsax.note_text),
                label: AppLocalizations.of(context)!.record,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.selectedIndex) {
      case 0:
        return AppLocalizations.of(context)!.home;
      case 1:
        return AppLocalizations.of(context)!.appointments;
      case 2:
        return AppLocalizations.of(context)!.my_children;
      case 3:
        return AppLocalizations.of(context)!.record;
      default:
        return '';
    }
  }
}
