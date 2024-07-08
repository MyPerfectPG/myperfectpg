import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeletePgOwnerScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete PG Owner',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),)),
      backgroundColor: Color(0xffF7F7F7),
      body: StreamBuilder(
        stream: _firestore.collection('pg_owners').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final pgOwners = snapshot.data!.docs;
          return ListView.builder(
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
                  iconColor: Colors.red,
                  leading: Icon(Icons.person_outline,size: 50,color: Color(0xff0094FF),),
                  title: Text(pgOwner['name'],
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),),
                  subtitle: Text(pgOwner['phone'],style: const TextStyle(
                      color: Colors.black, fontSize: 20),),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline,size: 50,),
                    onPressed: () {
                      _firestore.collection('pg_owners').doc(pgOwner.id).delete();
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




// child: ElevatedButton(
// onPressed: () {
// onTap();
// },
// child: Padding(
// padding: const EdgeInsets.symmetric(horizontal: 10),
// child: Column(
// children: [
// SizedBox(height: 10,),
// Center(child: Icon(icon_name,size: 100,color: Color(0xffE75480),)),
// Center(
// child: Text(
// title,
// style: const TextStyle(
// color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
// ),
// ),
// ],
// ),
// ),
// style: ButtonStyle(
// backgroundColor: MaterialStateProperty.resolveWith((states) {
// if (states.contains(MaterialState.pressed)) {
// return Colors.black26;
// }
// return Colors.white;
// }),
// shape: MaterialStateProperty.all<RoundedRectangleBorder>(
// RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
// ),