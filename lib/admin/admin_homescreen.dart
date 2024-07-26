import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_pg_owners.dart';
import 'admin_login.dart';
import 'delete_pg_owners.dart';
import 'pg_owner_screen.dart';
import 'book_request.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}


class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {

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


  Widget _navBar() {
    return Container(
      height: 65,
      margin: const EdgeInsets.only(right: 80, left: 80, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Icon(Icons.home_rounded, color: Color(0xff0094FF), size: 35),
            Icon(Icons.circle,color: Color(0xff0094FF),size: 5,)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: Colors.black),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print('Signed Out');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: TabBar(
            isScrollable: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(right: 8, left: 0), // Set left padding to 0
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xff0094FF),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero, // Remove any extra padding around the indicator
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color(0xff0094FF),
            ),
            tabs: [
              Tab(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff0094FF), width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add Owner",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff0094FF), width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Delete Owner",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff0094FF), width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Requests",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff0094FF), width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "View Owners",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _buildTabContent(
                context,
                "assets/images/add_pg1.jpg",
                AddPgOwnerScreen(),
              ),
              _buildTabContent(
                context,
                "assets/images/manage_pg1.jpg",
                DeletePgOwnerScreen(),
              ),
              _buildTabContent(
                context,
                "assets/images/add_pg1.jpg",
                ViewBookingsScreen(),
              ),
              _buildTabContent(
                context,
                "assets/images/add_pg1.jpg",
                PgOwnersScreen(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _navBar(),
    );
  }

  Widget _buildTabContent(BuildContext context, String imagePath, Widget nextPage) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.5,
          left: MediaQuery.of(context).size.width * 0.7,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
            },
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff0094FF),
              ),
              child: Icon(Icons.keyboard_arrow_right_outlined, color: Color(0xffF7F7F7)),
            ),
          ),
        ),
      ],
    );
  }
}