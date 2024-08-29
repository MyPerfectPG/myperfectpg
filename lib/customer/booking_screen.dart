import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('pgs')
                    .doc(booking['pgId'])  // Fetch pg document by pgId
                    .get(),
                builder: (context, pgSnapshot) {
                  if (pgSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (pgSnapshot.hasError || !pgSnapshot.hasData || !pgSnapshot.data!.exists) {
                    return ListTile(
                      title: Text(
                        booking['pgName'],
                        style: TextStyle(fontSize: 20),  // Increase text size
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location: ${booking['location']}',
                            style: TextStyle(fontSize: 16),  // Increase text size
                          ),
                        ],
                      ),
                    );
                  }

                  var pgData = pgSnapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic>? thumbnails = pgData['thumbnail'];

                  return Card(
                    child: ListTile(
                      leading: (thumbnails != null && thumbnails.isNotEmpty)
                          ? Image.network(
                        thumbnails[0],  // Display the first image in the thumbnail list
                        width: 80,  // Increase image width
                        height: 80,  // Increase image height
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.image_not_supported, size: 80),  // Increase icon size
                      title: Text(
                        booking['pgName'],
                        style: TextStyle(fontSize: 20),  // Increase text size
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location: ${booking['location']}',
                            style: TextStyle(fontSize: 16),  // Increase text size
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


/*
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
                  leading: booking['thumbnail'] != null
                      ? Image.network(
                    booking['thumbnail'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                  */
/*title: Text('PG: ${booking['pgName']}'),
                  subtitle: Text('Owner: ${booking['pgOwnerName']}'),*//*

                  title: Text(booking['pgName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      */
/*'₹${pgData!['price']}/month'*//*

                      */
/*Text('Price: ₹${booking['price']}'),*//*

                      Text('Location : ${booking['location']}'),
                      */
/*Text('Time at which booked: ${booking['timestamp']}'),*//*

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
*/
