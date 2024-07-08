import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/Page/reset_password.dart';
import 'package:myperfectpg/Page/signup.dart';
import 'package:myperfectpg/admin/admin_homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_auth_check.dart';
import '../components/resuable.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff0094FF),
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height*0.2, 20, MediaQuery.of(context).size.height*0.2),
          child: Column(
            children: <Widget>[
              logoWidget("assets/images/Artboard_2_copy_4-removebg-preview.png"),
              const SizedBox(
                height: 30,
              ),
              reusableTextField("Enter Username", Icons.person_outline, false, _emailTextController),
              const SizedBox(
                height: 30,
              ),
              reusableTextField("Enter Password", Icons.lock_outline, false, _passwordTextController),
              const SizedBox(
                height: 20,
              ),
              //forgetPassword(context),
              firebaseUIButton(context, "Sign In", (){
                try{
                  FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
                    snapshot.docs.forEach((result) async {
                      if (result.data()['id'] != _emailTextController.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              "Your id is not correct",
                              style: TextStyle(fontSize: 18.0),
                            )));
                      } else if (result.data()['password'] !=
                          _passwordTextController.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              "Your password is not correct",
                              style: TextStyle(fontSize: 18.0),
                            )));
                      } else {
                        Route route = MaterialPageRoute(builder: (context) => AdminHomeScreen());
                        var pref= await SharedPreferences.getInstance();
                        pref.setBool(AuthCheck.KEYLOGIN, true);
                        Navigator.pushReplacement(context, route);
                        // final SharedPreferences prefs = await SharedPreferences.getInstance();
                        // prefs.setString('id', _emailTextController.text);
                        // prefs.setString('id', _emailTextController.text);
                      }
                    });
                  });
                }catch (error) {
                  print("Error ${error.toString()}"); // Return the error code if user creation fails
                }
              }
              ),
              //signUpOption()
            ],
          ),),
        ),
      ),
    );
  }
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
  LoginAdmin(){
    try{
      FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
        snapshot.docs.forEach((result) {
          if (result.data()['id'] != _emailTextController.text.trim()) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.white,
                content: Text(
                  "Your id is not correct",
                  style: TextStyle(fontSize: 18.0),
                )));
          } else if (result.data()['password'] !=
              _passwordTextController.text.trim()) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.white,
                content: Text(
                  "Your password is not correct",
                  style: TextStyle(fontSize: 18.0),
                )));
          } else {
            Route route = MaterialPageRoute(builder: (context) => AdminHomeScreen());
            Navigator.pushReplacement(context, route);
          }
        });
      });
    }catch (error) {
      print("Error ${error.toString()}"); // Return the error code if user creation fails
    }
  }
}