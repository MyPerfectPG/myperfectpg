import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PgOwnersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PG Owners',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      backgroundColor: Color(0xffF7F7F7),
      body: StreamBuilder(
        stream: _firestore.collection('pg_owners').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final pgOwners = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: pgOwners.length,
            itemBuilder: (context, index) {
              final pgOwner = pgOwners[index];
              return Container(width: MediaQuery.of(context).size.width/0.2,
                height: 100,
                margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: ListTile(
                  leading: Icon(Icons.person_outline,size: 50,color: Color(0xff0094FF),),
                  title: Text(pgOwner['name'],style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),),
                  subtitle: Text(pgOwner['phone'],style: const TextStyle(
                      color: Colors.black, fontSize: 20),),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
