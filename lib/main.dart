import 'package:arabic_font/arabic_font.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/firebase_options.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';
import 'package:wiqaya_app/views/auth/login_screen.dart';
import 'package:wiqaya_app/views/auth/register_screen.dart';
import 'package:wiqaya_app/views/home_screen.dart';
import 'package:wiqaya_app/views/splash_screen.dart';
import 'package:wiqaya_app/views/welcome_screen.dart';

Future<void> main() async {
  // Initialize the app and Firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  await setupFCM();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const MyApp();
        },
      ),
    ),
  );
}

Future<void> setupFCM() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for iOS
  messaging.requestPermission();

  // Get the device token
  messaging.getToken().then((token) {
    print("FCM Token: $token");
  });

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message in foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Notification: ${message.notification!.title}');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //locale settings
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
      
      //theme settings
      theme: ThemeData(
        fontFamily:
            provider.locale.languageCode == 'ar'
                ? ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic)
                : ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic),
        package: ArabicThemeData.package,
        primaryColor: Color.fromRGBO(219, 235, 252, 1),
        secondaryHeaderColor: Color.fromRGBO(27, 83, 213, 1),
        canvasColor: Colors.white,

        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(fontSize: 20.sp),
          bodyLarge: TextStyle(fontSize: 16.sp),
          bodyMedium: TextStyle(fontSize: 14.sp),
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ),

      //routes settings
      initialRoute: '/splash',
      routes: {
        '/': (context) => const HomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
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

    return Scaffold();
  }
}
