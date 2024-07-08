import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_pg_screen.dart';

class ManagePGScreen extends StatelessWidget {
  final String pgId;

  ManagePGScreen({required this.pgId});
  Future<void> _deletePG(String id) async {
    await FirebaseFirestore.instance.collection('pgs').doc(pgId).delete();
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
            .where('ownerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final pgs = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: pgs.length,
            itemBuilder: (context, index) {
              var pg = pgs[index].data() as Map<String, dynamic>;
              var pgId = pgs[index].id;

              children:
              snapshot.data!.docs.map((doc) {
                return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 0.2,
                  height: 100,
                  margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: ListTile(
                    title: Text(pg['name'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,),),
                    subtitle: Text(pg['location'],
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 20),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_rounded, size: 40, color: Colors.black,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPGScreen(pgId: doc.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_outlined, size: 40,
                            color: Colors.red,),
                          onPressed: () => _deletePG(doc.id),
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
