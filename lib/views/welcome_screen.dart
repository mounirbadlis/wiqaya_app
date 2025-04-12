import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Image.asset(
                'assets/wiqaya_app_logo.png',
                width: 150,
                height: 150,
              ),
              Text(AppLocalizations.of(context)!.welcome_title,style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold,),),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.welcome_speech, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
              const Spacer(),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<LocaleProvider>(context, listen: false).changeLocale();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                  child: Text(AppLocalizations.of(context)!.login, style: TextStyle(color: Colors.white),),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                  },
                  child: Text(AppLocalizations.of(context)!.register, style: TextStyle(color: Colors.black),),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}