import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120.h,
            color: Theme.of(context).secondaryHeaderColor,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.w,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${User.user!.firstName[0]}${User.user!.familyName[0]}',
                      style: TextStyle(
                        fontSize: 24.w,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${User.user!.firstName} ${User.user!.familyName}',
                          style: TextStyle(
                            fontSize: 18.w,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          User.user!.phone,
                          style: TextStyle(
                            fontSize: 16.w,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions
          //vaccines
          ListTile(
            leading: const Icon(HugeIcons.strokeRoundedVaccine),
            title: Text(AppLocalizations.of(context)!.vaccines),
            onTap: () {
              Navigator.pushNamed(context, '/vaccines');
            },
          ),

          //centers
          ListTile(
            leading: const Icon(HugeIcons.strokeRoundedHospital01),
            title: Text(AppLocalizations.of(context)!.centers),
            onTap: () {
              Navigator.pushNamed(context, '/centers');
            },
          ),

          //postponed appointments
          ListTile(
            leading: const Icon(HugeIcons.strokeRoundedAppointment02),
            title: Text(AppLocalizations.of(context)!.postponed_appointments),
            onTap: () {
              Navigator.pushNamed(context, '/appointments/postponed');
            },
          ),

          // Settings
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              AppLocalizations.of(context)!.settings,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.global_edit_copy),
            title: Text(AppLocalizations.of(context)!.language),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          const Spacer(),
          ListTile(
            tileColor: Colors.red,
            textColor: Colors.white,
            iconColor: Colors.white,
            leading: const Icon(Iconsax.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.select_language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(AppLocalizations.of(context)!.logout_dialog_content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AuthController>(
                  context,
                  listen: false,
                ).logout().then((value) {
                  Navigator.pushNamed(context, '/welcome');
                });
              },
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
