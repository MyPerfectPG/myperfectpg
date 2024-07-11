import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/PG%20owner/add_pg_screen.dart';

import '../PG owner/edit_pg_screen.dart';
import 'admin_add_pg.dart';

class AddPGFlat extends StatefulWidget {
  final String pgId;

  AddPGFlat({required this.pgId});

  @override
  State<AddPGFlat> createState() => _AddPGFlatState();
}

class _AddPGFlatState extends State<AddPGFlat> {
  Future<void> _deletePG(String id) async {
    await FirebaseFirestore.instance.collection('pgs').doc(id).delete();
  }

  String? uid;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
      if (uid == null) {
        print('User is not authenticated.');
        // Handle the case where the user is not authenticated
        // For example, navigate to login screen or show a dialog
      } else {
        print('User is authenticated: ${uid}');
      }
    }
    else {
      print('User is not authenticated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Manage PGs',style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xff0094FF),),
      backgroundColor: Color(0xffF7F7F7),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pgs')
            .where('ownerId', isEqualTo: widget.pgId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final pgs = snapshot.data!.docs;
          return ListView(
            scrollDirection: Axis.vertical,
            children: snapshot.data!.docs.map((doc) {
              return Container(
                width: MediaQuery.of(context).size.width/0.2,
                height: 100,
                margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: ListTile(
                  title: Text(doc['name'],
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),),
                  subtitle: Text(doc['location'],
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500, fontSize: 25),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded,size: 50,color: Colors.black,),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPGScreen(pgId: doc.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_outlined,size: 50,color: Colors.red,),
                        onPressed: () => _deletePG(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.
          push(context, MaterialPageRoute(builder: (context)=>AddPGScreenAdmin(pgId: widget.pgId)));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
