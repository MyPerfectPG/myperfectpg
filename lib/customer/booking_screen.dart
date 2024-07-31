import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings',style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xff0094FF),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }

          var bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  /*title: Text('PG: ${booking['pgName']}'),
                  subtitle: Text('Owner: ${booking['pgOwnerName']}'),*/
                  title: Text(booking['pgName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*'₹${pgData!['price']}/month'*/
                      Text('Price: ₹${booking['price']}'),
                      Text('Location : ${booking['location']}'),
                      /*Text('Time at which booked: ${booking['timestamp']}'),*/
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
