import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(data['pgName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${data['customerName']}'),
                      Text('Customer Phone: ${data['customerPhone']}'),
                      Text('PG Owner: ${data['pgOwnerName']}'),
                      Text('PG Owner Phone: ${data['pgOwnerPhone']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      // Show confirmation dialog before deleting
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Booking'),
                          content: Text('Are you sure you want to delete this booking?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm) {
                        await FirebaseFirestore.instance
                            .collection('bookings')
                            .doc(doc.id)
                            .delete();
                      }
                    },
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
