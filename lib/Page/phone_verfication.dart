import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String phoneNumber;
  final String role;

  PhoneVerificationScreen({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _createUser();
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _createUser() async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      String collection =
      widget.role == 'customer' ? 'customers' : 'pgOwners';

      await _firestore.collection(collection).doc(userCredential.user!.uid).set({
        'email': widget.email,
        'phoneNumber': widget.phoneNumber,
        'role': widget.role,
      });

      _navigateToHomeScreen(widget.role);
    } catch (e) {
      print(e);
    }
  }

  void _navigateToHomeScreen(String role) {
    if (role == 'customer') {
      Navigator.pushReplacementNamed(context, '/customerHome');
    } else if (role == 'pgOwner') {
      Navigator.pushReplacementNamed(context, '/pgOwnerHome');
    }
  }

  void _verifyCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _codeController.text,
    );
    await _auth.signInWithCredential(credential);
    _createUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Verification Code'),
            ),
            ElevatedButton(
              onPressed: _verifyCode,
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
