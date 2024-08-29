import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myperfectpg/customer/Pg.dart';
import 'package:myperfectpg/customer/customer_login.dart';
import 'package:myperfectpg/customer/result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'booking_screen.dart';
import 'category_pg_list.dart';
import 'edit_profile.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> pgList = [];
  bool isLoading = true;
  int _currentPage = 0;

  String? _gender;
  String? _sharing;
  String? _fooding;
  String? _foodtype;
  String? _ac;
  String? _cctv;
  String? _wifi;
  String? _parking;
  String? _laundary;
  String? _profession;
  String? userName;
  String? emailId;
  String? uid;
  String? userImageUrl;

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
        // Fetch user image from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          userName = userDoc['name'] ?? 'User Name';
          emailId = userDoc['email'] ?? ' ';
          userImageUrl = userDoc['imageUrl'] ?? null;
        });
      }
    } else {
      print('User is not authenticated.');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _fetchRandomPGs();
    _pageController.addListener(() {
      int nextPage = _pageController.page?.round() ?? 0;
      if (_currentPage != nextPage) {
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
    // Initialize variables with default values if needed
    _gender = '';
    _sharing = '';
    _fooding = '';
    _foodtype = '';
    _ac = '';
    _cctv = '';
    _wifi = '';
    _parking = '';
    _laundary = '';
    _profession = '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Inside your existing code


  Future<void> _fetchRandomPGs() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('pgs').get();
      List<DocumentSnapshot> docs = snapshot.docs;

      if (docs.isEmpty) {
        print("No documents found in the 'pgs' collection.");
        return;
      }

      List<Map<String, dynamic>> pgs = [];
      Random random = Random();

      // Repeat the PGs if there are fewer than 5
      while (pgs.length < 5 && docs.isNotEmpty) {
        for (int i = 0; i < docs.length && pgs.length < 5; i++) {
          DocumentSnapshot doc = docs[random.nextInt(docs.length)];
          Map<String, dynamic> pgData = doc.data() as Map<String, dynamic>;

          // Debugging: Print the document data
          print("Document data: $pgData");

          List<dynamic> thumbnailList = pgData['thumbnail'] ?? [];
          String thumbnail = thumbnailList.isNotEmpty ? thumbnailList[0] : ''; // Get the first thumbnail URL

          if (thumbnail.isNotEmpty) {
            pgs.add({
              'id': doc.id,
              'name': pgData['name'] ?? 'No Name',
              'summary': pgData['summary'] ?? 'No Summary',
              'image': thumbnail, // Use the first thumbnail field
            });

            // Remove the selected doc to avoid duplication
            docs.remove(doc);
          }
        }
      }

      setState(() {
        pgList = pgs.take(5).toList();
        isLoading = false;
      });

      // Debugging: Print the final list of PGs
      print("Fetched PG List: $pgList");

    } catch (e) {
      print("Error fetching PGs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /*Future<void> _fetchRandomPGs() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('pgs').get();
      List<DocumentSnapshot> docs = snapshot.docs;
      List<Map<String, dynamic>> pgs = [];
      Random random = Random();

      // Repeat the PGs if there are fewer than 5
      while (pgs.length < 5 && docs.isNotEmpty) {
        for (int i = 0; i < docs.length && pgs.length < 5; i++) {
          DocumentSnapshot doc = docs[random.nextInt(docs.length)];
          Map<String, dynamic> pgData = doc.data() as Map<String, dynamic>;
          String thumbnail = pgData['thumbnail'] ?? ''; // Get the thumbnail field
          if (thumbnail.isNotEmpty) {
            pgs.add({
              'id': doc.id,
              'name': pgData['name'],
              'summary': pgData['summary'],
              'image': thumbnail, // Use the thumbnail field
            });
          }
        }
      }

      setState(() {
        pgList = pgs.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching PGs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }*/

  Future<List<Map<String, dynamic>>> _fetchPGsByCategory(String category) async {
    QuerySnapshot snapshot;
    if (category == 'Boys') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('gender', whereIn: ['Boys', 'Both'])
          .get();
    } else if (category == 'Girls') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('gender', whereIn: ['Girls', 'Both'])
          .get();
    } else if (category == 'AC') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('ac', isEqualTo: 'Available')
          .get();
    } else if (category == 'Non AC') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('ac', isEqualTo: 'Not Available')
          .get();
    } else if (category == 'Single') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('sharing', isEqualTo: 'Single')
          .get();
    } else if (category == 'Double') {
      snapshot = await FirebaseFirestore.instance
          .collection('pgs')
          .where('sharing', isEqualTo: 'Double')
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance.collection('pgs').get();
    }

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'summary': doc['summary'],
      'image': (doc['images'] as List<dynamic>).first,
    })
        .toList();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName ?? 'User Name'),
              accountEmail: Text(emailId ?? 'user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: userImageUrl != null
                    ? NetworkImage(userImageUrl!)
                    : AssetImage('lib/assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('My Bookings'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyBookingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () async {
                bool signOutConfirmed =
                await _showSignOutConfirmationDialog(context);
                if (signOutConfirmed) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 400,
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : pgList.isEmpty
                        ? Center(child: Text('No images available'))
                        : PageView.builder(
                      controller: _pageController,
                      itemCount: pgList.length,
                      itemBuilder: (context, index) {
                        var pg = pgList[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              pg['image'],
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pg['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    pg['summary'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Pg(pgId: pg['id']),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 34),
                                    ),
                                    child: Text(
                                      'Book Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${pgList.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    right: 5,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: userImageUrl != null
                                    ? NetworkImage(userImageUrl!)
                                    : AssetImage(
                                    'lib/assets/default_avatar.png')
                                as ImageProvider,
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: userImageUrl == null
                                    ? Icon(Icons.menu, color: Colors.white)
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _buildSearchBar(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _categorySection(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for PG',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
                onSubmitted: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsScreen(),
                      settings: RouteSettings(
                        arguments: {'query': value},
                      ),
                    ),
                  );
                },
              ),
            ),
            Icon(Icons.search, color: Colors.blue), // Search icon on the right side
          ],
        ),
      ),
    );
  }

  Widget _categorySection() {
    List<Map<String, String>> categories = [
      {'title': 'Boys', 'imagePath': 'lib/assets/boys.png'},
      {'title': 'Girls', 'imagePath': 'lib/assets/girls.png'},
      {'title': 'Both', 'imagePath': 'lib/assets/girls.png'},
      {'title': 'AC', 'imagePath': 'lib/assets/ac.png'},
      {'title': 'Non AC', 'imagePath': 'lib/assets/non-ac.png'},
      {'title': 'Single', 'imagePath': 'lib/assets/categories.png'},
      {'title': 'Double', 'imagePath': 'lib/assets/categories.png'},
      {'title': 'Triple', 'imagePath': 'lib/assets/categories.png'},
    ];

    return Column(
      children: List.generate((categories.length / 2).ceil(), (index) {
        int leftIndex = index * 2;
        int rightIndex = leftIndex + 1;

        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (leftIndex < categories.length)
                _categoryCard(
                  categories[leftIndex]['title']!,
                  categories[leftIndex]['imagePath']!,
                ),
              SizedBox(width: 10), // Adjust the width as needed for spacing
              if (rightIndex < categories.length)
                _categoryCard(
                  categories[rightIndex]['title']!,
                  categories[rightIndex]['imagePath']!,
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<bool> _showSignOutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print('Signed Out');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerLoginScreen()),
                );
              });
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _categoryCard(String title, String imagePath) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPGListScreen(category: title),
            ),
          );
        },
        child: Container(
          width: 150,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
