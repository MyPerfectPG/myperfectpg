import 'package:flutter/material.dart';

class BookingSplashScreen extends StatelessWidget {
  final String customerName;
  final String customerPhoneNumber;
  final String pgName;

  BookingSplashScreen({
    required this.customerName,
    required this.customerPhoneNumber,
    required this.pgName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'You will be contacted soon',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
