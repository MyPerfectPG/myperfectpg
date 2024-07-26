import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/PG%20owner/owner_home.dart';
import 'package:myperfectpg/Page/reset_password.dart';
import 'package:myperfectpg/Page/signup.dart';
import 'package:myperfectpg/components/resuable.dart';
import 'package:myperfectpg/customer/customer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAccScreen extends StatefulWidget {
  const LoginAccScreen({super.key});

  @override
  State<LoginAccScreen> createState() => _LoginAccScreenState();
}

class _LoginAccScreenState extends State<LoginAccScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'Customer';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // Navigate to the appropriate screen based on stored role
      String role = prefs.getString('role') ?? 'customer';
      _navigateToHomeScreen(role);
    }
  }

  void _navigateToHomeScreen(String role) {
    if (role == 'Customer') {
      // Navigate to customer home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CustomerHome()));
    } else {
      // Navigate to PG owner home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    }
  }

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('role', _role);
      _navigateToHomeScreen(_role);
    } catch (e) {
      // Handle login error
      print(e);
    }
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () =>
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResetPassword())),
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
                reusableTextField("Enter Email ID", Icons.person_outline, false, _emailController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordController),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(height: 10,),
                DropdownButtonFormField(onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                  items: <String>['Customer','PG owner']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,),
                    );
                  }).toList(),decoration: InputDecoration(
                    hintText: "Role",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),borderSide: const BorderSide(width: 0,style: BorderStyle.none)),
                  ),),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", _login),
                signUpOption()
              ],
            ),),
        ),
      ),
    );
  }
  }