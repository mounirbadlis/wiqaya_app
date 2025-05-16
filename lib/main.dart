import 'package:arabic_font/arabic_font.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/controllers/historical_record_controller.dart';
import 'package:wiqaya_app/controllers/vaccine_controller.dart';
import 'package:wiqaya_app/firebase_options.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';
import 'package:wiqaya_app/views/appointment/appointment_details_screen.dart';
import 'package:wiqaya_app/views/appointment/appointments_screen.dart';
import 'package:wiqaya_app/views/auth/login_screen.dart';
import 'package:wiqaya_app/views/auth/register_screen.dart';
import 'package:wiqaya_app/views/children/add_child_screen.dart';
import 'package:wiqaya_app/views/children/child_history_screen.dart';
import 'package:wiqaya_app/views/children/children_screen.dart';
import 'package:wiqaya_app/views/children/required_ages_screen.dart';
import 'package:wiqaya_app/views/main_screen.dart';
import 'package:wiqaya_app/views/splash_screen.dart';
import 'package:wiqaya_app/views/vaccine/vaccine_details_screen.dart';
import 'package:wiqaya_app/views/vaccine/vaccines_screen.dart';
import 'package:wiqaya_app/views/welcome_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

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
  await requestMapPermission();
  MapboxOptions.setAccessToken('pk.eyJ1IjoibW91bmlyYmFkbGlzMiIsImEiOiJjbTl6emg5YjgwaGRyMmxzZng1cTkxa256In0.FCAWFO7Iqz5t4u2dGqSDwA');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ChildrenController()),
        ChangeNotifierProvider(create: (_) => HistoricalRecordController()),
        ChangeNotifierProvider(create: (_) => VaccineController()),
        ChangeNotifierProvider(create: (_) => AppointmentController()),
      ],
      child: ScreenUtilInit(
        //designSize: const ui.Size(375, 812),
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
  // Foreground message handler<<
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message in foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Notification: ${message.notification!.title}');
    }
  });
}

  Future<void> requestMapPermission() async {
    geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
    if(permission == geolocator.LocationPermission.denied){
      permission = await geolocator.Geolocator.requestPermission();
      if(permission == geolocator.LocationPermission.deniedForever){
        return;
      }
    }
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //locale settings
      locale: localeProvider.locale,
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
            localeProvider.locale.languageCode == 'ar'
                ? ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic)
                : ArabicThemeData.font(arabicFont: ArabicFont.dinNextLTArabic),
        package: ArabicThemeData.package,

        //colors
        primaryColor: Color.fromRGBO(243,240,247,1),
        secondaryHeaderColor: Color.fromRGBO(27, 83, 213, 1),

        //text theme
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
        '/main': (context) => SafeArea(child: MainScreen()),
        
        //children
        '/children': (context) => const ChildrenScreen(),
        '/children/child_history': (context) => ChildHistoryScreen(child: Provider.of<ChildrenController>(context, listen: false).selectedChild!,),
        '/children/add': (context) => const AddChildScreen(),
        '/children/add/next': (context) => const RequiredAgesScreen(),

        //vaccines
        '/vaccines': (context) => const VaccinesScreen(),
        '/vaccines/vaccine_details': (context) => VaccineDetailsScreen(),

        //appointments
        '/appointments': (context) => const AppointmentsScreen(),
        '/appointments/details': (context) => AppointmentDetailsScreen(),

        //splash
        '/splash': (context) => const SplashScreen(),

        //auth
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
