import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';
import 'package:wiqaya_app/views/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: provider.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        fontFamily: provider.locale.languageCode == 'ar' ? ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic) : ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic),
        package: ArabicThemeData.package,
        primaryColor: Color.fromRGBO(219,235,252, 1),
        secondaryHeaderColor: Color.fromRGBO(27,83,213, 1),
        canvasColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            provider.changeLocale();
          },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(HugeIcons.strokeRoundedBuilding06, size: 50,),
            Text(AppLocalizations.of(context)!.login, style: TextStyle(fontSize: 30),),
          ],
        )),
      ),
    );
  }
}
