import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/PG%20owner/pg_auth_check.dart';
import 'package:myperfectpg/PG%20owner/pg_login.dart';
import 'package:myperfectpg/Page/login.dart';
import 'package:myperfectpg/admin/admin_login.dart';
import 'package:myperfectpg/customer/customer_auth.dart';
import 'admin/admin_auth_check.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>  {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home:  AnimatedSplashScreen(
        splash: 'assets/images/Artboard_2_copy_4-removebg-preview.png',
        splashIconSize: 450,
        nextScreen: PGAuthCheck(),
        backgroundColor: Color(0xff0094FF),
        duration: 1000,
        // splashTransition: SplashTransition.rotationTransition,
        // pageTransitionType: PageTransitionType.scale,
      ),
    );
  }
}