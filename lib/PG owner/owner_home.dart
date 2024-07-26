import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:myperfectpg/PG%20owner/pg_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/admin_auth_check.dart';
import 'add_pg_screen.dart';
import 'manage_pg_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  /*User? user;

  @override
  void initState() {
    super.initState();
    checkAuthState(); // Check authentication state when the screen initializes
  }

  void checkAuthState() {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      // Handle the case where the user is not authenticated
      // For example, navigate to login screen or show a dialog
    } else {
      print('User is authenticated: ${user!.uid}');
    }
  }*/
  /*String? uid;
  Map<String, dynamic>? pgOwnerData;*/

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

  /*@override
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
      checkAuthState(user.uid);
    }
  }
  void checkAuthState(String uid)async {

    if (uid == null) {
      print('User is not authenticated.');
      // Handle the case where the user is not authenticated
      // For example, navigate to login screen or show a dialog
    } else {
      print('User is authenticated: ${uid}');
    }
  }*/
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);
  // }
  //
  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  Widget _navBar(){
    return Container(
      height: 65,
      margin: const EdgeInsets.only(
        right: 80,
        left: 80,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 10,
          )
        ]
      ),child: Padding(
      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/4, 15, 0, 0),
        child: Row(
          children: [
            Column(
              children: [
                Icon(Icons.home_rounded,color: Color(0xff0094FF),size: 30,),
                Icon(Icons.circle,color: Color(0xff0094FF),size: 5,)
              ],
            ),
          ],
        ),
      ),
      // child: Row(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: navIcons.map((icon){
      //     return Material(
      //       color:  Colors.transparent,
      //       child: Column(
      //         children: [
      //           Container(
      //             alignment: Alignment.center,
      //             margin: EdgeInsets.only(
      //               top: 15,
      //               bottom: 0,
      //               left: 35,
      //               right: 35,
      //             ),
      //             child: Icon(icon,color: Colors.white,),
      //           )
      //         ],
      //       ),
      //     );
      //   }),
      // ),
    );
  }


  Stream<QuerySnapshot> getPGsForCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('pgs')
        .where('ownerId', isEqualTo: user!.uid)
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Container(
            child:
            Column(
              children: [
                SizedBox(height: 10,),
                Text('Home',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),),
              ],
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OwnerLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Material(
                child: Container(
                  height: 60,
                  color: Colors.white,
                  child: TabBar(
                      //controller: _tabController,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      labelColor: Colors.white,
                      unselectedLabelColor: Color(0xff0094FF),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff0094FF),
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Color(0xff0094FF),width: 2),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Add PG",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Color(0xff0094FF),width: 2),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Manage PG",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              Expanded(
                  child: TabBarView(
                    //controller: _tabController,
                    children: [
                      Stack(

                        children:[
                          Positioned(
                            top:  MediaQuery.of(context).size.height*.1,
                            left: MediaQuery.of(context).size.width*.1,
                            child: Container(
                              height: MediaQuery.of(context).size.height/2,
                              width:  MediaQuery.of(context).size.width*.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.asset("assets/images/add_pg1.jpg",fit: BoxFit.cover,)),
                            ),
                          ),
                          Positioned(
                            top:  MediaQuery.of(context).size.height*.5,
                            left: MediaQuery.of(context).size.width*.7,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddPGScreen()));
                              },
                              child: Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.keyboard_arrow_right_outlined,color: Color(0xffF7F7F7),),
                              ),
                            ),
                          ),
                        ],),
                      Stack(

                        children:[
                          Positioned(
                            top:  MediaQuery.of(context).size.height*.1,
                            left: MediaQuery.of(context).size.width*.1,
                            child: Container(
                              height: MediaQuery.of(context).size.height/2,
                              width:  MediaQuery.of(context).size.width*.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.asset("assets/images/manage_pg1.jpg",fit: BoxFit.cover,)),
                            ),
                          ),
                          Positioned(
                            top:  MediaQuery.of(context).size.height*.5,
                            left: MediaQuery.of(context).size.width*.7,
                            child: GestureDetector(
                              onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManagePGScreen()));
                              },
                              child: Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.keyboard_arrow_right_outlined,color: Color(0xffF7F7F7),),
                              ),
                            ),
                          ),
                        ],),
                      /*Container(
                        height: 500,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset("assets/images/manage_pg.jpg"),
                      ),*/
                    ],
                  ),
              ),
            ],
          ),
        ),
          Align(alignment: Alignment.bottomCenter,child: _navBar())
        ]
      ),


      // bottomNavigationBar: ,

    );
  }
}



// mainAxisAlignment: MainAxisAlignment.start,
// children: [
// Material(child:
// SizedBox(height: 20,width: 20,),
// buttonPG(context, 'Add PG', Icons.add_home_outlined, () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => AddPGScreen()),
// );
// },),
// SizedBox(height: 10,width: 20,),
// buttonPG(context, 'Manage PGs', Icons.manage_accounts_outlined, () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => ManagePGScreen()),
// );
// },),