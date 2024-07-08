import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/components/resuable.dart';

class AddPgOwnerScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
            buttonPG(context, 'Add', Icons.abc, (){
              _firestore.collection('pg_owners').add({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
              });
              Navigator.pop(context);
            }
            ),
          ],
        ),
      ),
    );
  }
}
