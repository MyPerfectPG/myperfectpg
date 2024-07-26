import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/components/resuable.dart';
import 'dart:math';

class AddPgOwnerScreen extends StatelessWidget {
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
      appBar: AppBar(title: Text('Add PG Owner')),
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
            DataTextField('Password', Icons.shield_outlined, false, pwdController),
            SizedBox(height: 20,),
            buttonPG(context, 'Add', Icons.abc,() async {
              try {
                // Create user in Firebase Authentication
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: pwdController.text,
                );

                // Get the UID of the newly created user
                String uid = userCredential.user?.uid ?? '';

                // Prepare user details to be stored in Firestore
                Map<String, dynamic> pgOwnerDetails = {
                  'uid': uid,
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'password':pwdController.text,// Optionally store the email as well
                  // Add other necessary details here
                };

                // Store user details in Firestore under the 'pg_owners' collection
                await FirebaseFirestore.instance.collection('pg_owners').doc(uid).set(pgOwnerDetails);

                print('PG Owner registered successfully!');
                Navigator.pop(context);
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
  }
}
