import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewBookingRequestsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Requests')),
      body: StreamBuilder(
        stream: _firestore.collection('booking_requests').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bookingRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookingRequests.length,
            itemBuilder: (context, index) {
              final request = bookingRequests[index];
              return ListTile(
                title: Text(request['student_name']),
                subtitle: Text(request['request_date']),
                onTap: () {
                  // Handle booking request details
                },
              );
            },
          );
        },
      ),
    );
  }
}
