import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/provider/country_provider.dart';
import 'package:prabodham/provider/promocode_provider.dart';
import 'package:prabodham/provider/reset_password_provider.dart';
import 'package:prabodham/provider/signin_provider.dart';
import 'package:prabodham/provider/signup_provider.dart';
import 'package:prabodham/screen/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignUpProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignInProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ResetPasswordProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CountryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromoCodeProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Prabodham',
        debugShowCheckedModeBanner: false,
        theme: CustomAppTheme.lightTheme,
        themeMode: ThemeMode.light,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: SplashScreen(),
      ),
    );
  }
}
