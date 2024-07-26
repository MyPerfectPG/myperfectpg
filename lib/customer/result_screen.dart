import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Pg.dart';

class SearchResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String query = args['query'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Search Results')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('pgs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
            return doc['name'].toLowerCase().contains(query.toLowerCase()) ||
                doc['location'].toLowerCase().contains(query.toLowerCase());
          }).toList();
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = docs[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['location']),
                leading: Image.network(doc['images'][0], fit: BoxFit.cover, width: 50, height: 50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>Pg(pgId: doc.id,
                      )),
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
