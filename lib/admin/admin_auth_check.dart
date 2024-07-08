import 'package:flutter/material.dart';
import 'package:myperfectpg/admin/admin_login.dart';
import 'package:myperfectpg/admin/admin_homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});
  static const String KEYLOGIN="Login";

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState(){
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void whereToGo()async{
     var pref= await SharedPreferences.getInstance();
     var isLoggedIn=pref.getBool(AuthCheck.KEYLOGIN);
     if(isLoggedIn!=null){
       if(isLoggedIn){
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomeScreen(),));
       }else{
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen(),));
       }
     }else{
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen(),));
     }
  }

}
