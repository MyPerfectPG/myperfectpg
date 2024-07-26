import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myperfectpg/Page/login.dart';
import 'package:myperfectpg/Page/phone_verfication.dart';
import 'package:myperfectpg/customer/customer_home.dart';
import '../components/resuable.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                        Map<String, dynamic> Details = {
                        'uid': uid,
                        'name': _userNameTextController,
                        'phone': _phoneTextController,
                        'email': _emailTextController.text,
                        'password':_passwordTextController.text,// Optionally store the email as well
                        // Add other necessary details here
                        };
                        String collection = _role == 'Customer' ? 'users' : 'pg_owners';


                        // Store user details in Firestore under the 'pg_owners' collection
                        await FirebaseFirestore.instance.collection(collection).doc(userCredential.user!.uid).set(Details);

                        print('User registered successfully!');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhoneVerificationScreen(
                                email: _emailTextController.text,
                                password: _passwordTextController.text,
                                phoneNumber: _phoneTextController.text,
                                role: _role,
                              ),
                            ),
                          );
                        } catch (e) {
                        print('Error registering User: $e');
                        }
                    })
                  ],
                ),
              ))),
    );
  }
}
