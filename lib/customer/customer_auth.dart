import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/customer/customer_login.dart';
import 'package:myperfectpg/customer/customer_home.dart';


class CustomerAuth extends StatefulWidget {
  const CustomerAuth({super.key});

  @override
  State<CustomerAuth> createState() => _CustomerAuthState();
}

class _CustomerAuthState extends State<CustomerAuth> {
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
      home: isLogin ?  CustomerHome(): CustomerLoginScreen(),
    );
  }
}
