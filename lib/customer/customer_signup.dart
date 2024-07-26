import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myperfectpg/PG%20owner/owner_home.dart';
import 'package:myperfectpg/Page/login.dart';
import 'package:myperfectpg/Page/phone_verfication.dart';
import 'package:myperfectpg/customer/customer_home.dart';
import '../components/resuable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  /*String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up',style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),backgroundColor: Color(0xff0094FF),foregroundColor: Colors.white,),
      backgroundColor: Color(0xffF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DataTextField('Name', Icons.person_outline, false, nameController),
            SizedBox(height: 20,),
            DataTextField('Email ID', Icons.mail_outline_rounded, false, emailController),
            SizedBox(height: 20,),
            DataTextField('Phone Number', Icons.phone_outlined, false, phoneController),
            SizedBox(height: 20,),
            DataTextField('Password  (atleast 6 characters)', Icons.shield_outlined, false, pwdController),
            SizedBox(height: 20,),
            buttonPG(context, 'Signup', Icons.abc,() async {
              try {
                // Create user in Firebase Authentication
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: pwdController.text,
                );

                // Get the UID of the newly created user
                String uid = userCredential.user?.uid ?? '';

                // Prepare user details to be stored in Firestore
                Map<String, dynamic> CustomerDetails = {
                  'uid': uid,
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'password':pwdController.text,// Optionally store the email as well
                  // Add other necessary details here
                };

                // Store user details in Firestore under the 'pg_owners' collection
                await FirebaseFirestore.instance.collection('users').doc(uid).set(CustomerDetails);

                print('Customer registered successfully!');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerHome()
                  ),
                );
              } catch (e) {
                print('Error registering PG Owner: $e');
              }
            }
              /*(){
              _firestore.collection('pg_owners').add({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'password':pwdController.text,

              });
              Navigator.pop(context);
            }*/
            ),
          ],
        ),
      ),
    );
  }/*
  TextEditingController _phoneTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  String _role = 'Customer';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Color(0xff0094FF)),
          child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter UserName", Icons.person_outline, false,
                        _userNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Id", Icons.person_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Phone Number", Icons.phone_outlined, false,
                        _phoneTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_outlined, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    firebaseUIButton(context, "Sign Up", () async {
                      try {
                      // Create user in Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text,
                      );

                      // Get the UID of the newly created user
                      String uid = userCredential.user?.uid ?? '';

                      // Prepare user details to be stored in Firestore
                      Map<String, dynamic> pgOwnerDetails = {
                      'uid': uid,
                      'name': _userNameTextController,
                      'phone': _phoneTextController,
                      'email': _emailTextController.text,
                      'password':_passwordTextController.text,// Optionally store the email as well
                      // Add other necessary details here
                      };

                      // Store user details in Firestore under the 'pg_owners' collection
                      await FirebaseFirestore.instance.collection('pg_owners').doc(uid).set(pgOwnerDetails);

                      print('PG Owner registered successfully!');
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => HomeScreen()
                      ),
                      );
                      } catch (e) {
                      print('Error registering PG Owner: $e');
                      }
                    })
                  ],
                ),
              ))),
    );
  }*/
}
