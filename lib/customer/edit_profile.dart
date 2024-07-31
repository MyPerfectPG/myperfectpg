import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myperfectpg/components/resuable.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xff0094FF),),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Error fetching user data.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = userData['name'];
          _phoneController.text = userData['phone'];
          _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
          _imageUrl = userData['imageUrl'];

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_imageUrl != null ? NetworkImage(_imageUrl!) : AssetImage('lib/assets/default_avatar.png')) as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  DataTextField("Username", Icons.person_outline, false, _nameController),
                  /*TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),*/
                  SizedBox(height: 8),
                  DataTextField("Phone Number", Icons.phone_outlined, false, _phoneController),
                  /*TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),*/
                  SizedBox(height: 8),
                  DataTextField("Email ID", Icons.email_outlined, false, _emailController),
                  /*TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),*/
                  SizedBox(height: 16),
                  Center(child: buttonPG(context, "Save", Icons.abc, _updateProfile))
                  /*ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Save'),
                  ),*/
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${FirebaseAuth.instance.currentUser?.uid}');
      final uploadTask = storageReference.putFile(_imageFile!);
      final downloadUrl = await (await uploadTask).ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      String? newEmail = _emailController.text.trim();
      if (newEmail != FirebaseAuth.instance.currentUser?.email) {
        try {
          await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
        } catch (e) {
          print('Error updating email: $e');
          return;
        }
      }

      await _uploadImage();

      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'imageUrl': _imageUrl,
      });

      Navigator.pop(context);
    }
  }
}
