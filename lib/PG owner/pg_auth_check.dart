import 'package:flutter/material.dart';
import 'package:myperfectpg/PG%20owner/owner_home.dart';
import 'package:myperfectpg/PG%20owner/pg_login.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PGAuthCheck extends StatefulWidget {
  const PGAuthCheck({super.key});
  static const String KEYLOGIN="Login";

  @override
  State<PGAuthCheck> createState() => _PGAuthCheckState();
}

class _PGAuthCheckState extends State<PGAuthCheck> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void whereToGo() async {
    var pref = await SharedPreferences.getInstance();
    var isLoggedIn = pref.getBool(PGAuthCheck.KEYLOGIN);
    if (isLoggedIn != null) {
      if (isLoggedIn) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(),));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OwnerLoginScreen(),));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OwnerLoginScreen(),));
    }
  }
}