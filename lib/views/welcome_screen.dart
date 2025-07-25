import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result) {
        if(!didPop) {return;}
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
      
                // Logo
                Image.asset(
                  'assets/logo/wiqaya_app_logo.png',
                  width: 150.w,
                  height: 150.h,
                ),
      
                Text(
                  AppLocalizations.of(context)!.welcome_title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                      ),
                ),
      
                SizedBox(height: 20.h),
      
                Text(
                  AppLocalizations.of(context)!.welcome_speech,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                      ),
                ),
      
                const Spacer(),
      
                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(AppLocalizations.of(context)!.login, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),),
                  ),
                ),
      
                SizedBox(height: 16.h),
      
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.register,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black),
                    ),
                  ),
                ),
      
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
