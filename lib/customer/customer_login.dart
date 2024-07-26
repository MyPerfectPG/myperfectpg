import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/customer/customer_home.dart';
import 'package:myperfectpg/Page/reset_password.dart';
import 'package:myperfectpg/Page/signup.dart';
import '../components/resuable.dart';
import 'customer_signup.dart';
// Ensure you import the HomeScreen or relevant next screen.

class CustomerLoginScreen extends StatefulWidget {
  @override
  _CustomerLoginScreenState createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  TextEditingController countryController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<void> _signIn() async {
    try {
      await signInWithPhoneAndPassword(
        _phoneController.text,
        _passwordController.text,
      );
      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomerHome()),
      );
    } catch (e) {
      print(e);
      // Handle errors, e.g., show a snackbar or dialog
    }
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
                reusableTextField("Enter Phone Number", Icons.phone_outlined, false, _phoneController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.password_outlined, false, _passwordController),
                const SizedBox(
                  height: 20,
                ),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", _signIn),
                signUpOption()
              ],
            ),),
        ),
      ),
    );
  }

  Future<void> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query Firestore to find the user document with the matching phone number
    QuerySnapshot query = await firestore.collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot doc = query.docs.first;
      String email = doc['email'];

      // Sign in with the retrieved email and password
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } else {
      throw Exception('No user found for that phone number.');
    }
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
                MaterialPageRoute(builder: (context) => CustomerSignUpScreen()));
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
}
