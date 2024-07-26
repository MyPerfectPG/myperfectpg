import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/PG%20owner/owner_home.dart';
import 'package:myperfectpg/PG%20owner/pg_signup.dart';
import 'package:myperfectpg/Page/reset_password.dart';
import 'package:myperfectpg/Page/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/admin_auth_check.dart';
import '../components/resuable.dart';
 // Ensure you import the HomeScreen or relevant next screen.

class OwnerLoginScreen extends StatefulWidget {
  @override
  _OwnerLoginScreenState createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    final String email = _emailTextController.text;
    final String password = _passwordTextController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot adminSnapshot = await _firestore
          .collection('pg_owners')
          .doc(userCredential.user?.uid)
          .get();

      if (adminSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        await _auth.signOut();
        _showError('Not an PG Owner');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }
  void _showError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
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
                reusableTextField("Enter Email ID", Icons.person_outline, false, _emailTextController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, false, _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", _login),
                signUpOption()
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
                MaterialPageRoute(builder: (context) => PGSignUpScreen()));
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
  // LoginAdmin() {
  //   try {
  //     FirebaseFirestore.instance.collection("pg_owners").get().then((snapshot) {
  //       snapshot.docs.forEach((result) {
  //         if (result.data()['name'] != _emailTextController.text.trim()) {
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               backgroundColor: Colors.white,
  //               content: Text(
  //                 "Your id is not correct",
  //                 style: TextStyle(fontSize: 18.0),
  //               )));
  //         } else if (result.data()['email'] !=
  //             _passwordTextController.text.trim()) {
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               backgroundColor: Colors.white,
  //               content: Text(
  //                 "Your password is not correct",
  //                 style: TextStyle(fontSize: 18.0),
  //               )));
  //         } else {
  //           Route route = MaterialPageRoute(
  //               builder: (context) => AdminHomeScreen());
  //           Navigator.pushReplacement(context, route);
  //         }
  //       });
  //     });
  //   } catch (error) {
  //     print("Error ${error
  //         .toString()}"); // Return the error code if user creation fails
  //   }
  // }
}
