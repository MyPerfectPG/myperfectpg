import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/admin/admin_login.dart';
import 'package:myperfectpg/admin/admin_homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  var auth=FirebaseAuth.instance;
  var isLogin=false;

  checkIfLogin()async{
    auth.authStateChanges().listen((User?user) {
      if(user!=null && mounted){
        setState(() {
          isLogin=true;
        });
      }
    });
  }

  @override
  void initState(){
    checkIfLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLogin ?  AdminHomeScreen(): LoginScreen(),
    );
  }

}
