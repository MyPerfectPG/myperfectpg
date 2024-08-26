import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Pg.dart';

class SearchResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String query = args['query'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Search Results',style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),backgroundColor: Color(0xff0094FF),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('pgs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Filter documents based on the query
          List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
            return doc['name'].toLowerCase().contains(query.toLowerCase()) ||
                doc['location'].toLowerCase().contains(query.toLowerCase());
          }).toList();

          // Display "No results found" if the list is empty
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No results found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Display results in a ListView
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = docs[index];
              // Safeguard against empty 'images' list
              List<dynamic> images = doc['thumbnail'];
              String imageUrl = images.isNotEmpty ? images[0] : ''; // Default to empty string if no image

              return ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: SizedBox(
                  width: 100, // Adjust the width of the image
                  height: 100, // Adjust the height of the image
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 50), // Placeholder icon if image URL is empty
                ),
                title: Text(
                  doc['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Increased font size
                ),
                subtitle: Text(
                  doc['location'],
                  style: TextStyle(fontSize: 16), // Slightly larger font size
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Pg(pgId: doc.id)),
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
