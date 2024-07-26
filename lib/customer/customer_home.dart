import 'package:flutter/material.dart';
import 'package:myperfectpg/customer/Pg.dart';
import 'package:myperfectpg/customer/result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'category_pg_list.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> pgList = [];
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _fetchRandomPGs();
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

  /*@override
  void initState() {
    super.initState();
    _fetchRandomPGs();
  }*/

  Future<void> _fetchRandomPGs() async {
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
          List<String> images = List<String>.from(pgData['images']);
          if (images.isNotEmpty) {
            pgs.add({
              'id': doc.id,
              'name': pgData['name'],
              'summary': pgData['summary'],
              'image': images[0], // You can also select a random image from the list
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 16), // Removed top padding only
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  // Slideshow Section
                  SizedBox(
                    height: 400, // Adjust height as needed
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          builder: (context) => Pg(pgId: pg['id']
                                            ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 34),
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
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildSearchBar(), // Search bar positioned on top of the image
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
                child: _categorySection(), // Display categories section
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
                  prefixIcon: Icon(Icons.search),
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
      {'title': 'AC', 'imagePath': 'lib/assets/ac.png'},
      {'title': 'Non AC', 'imagePath': 'lib/assets/non-ac.png'},
      {'title': 'Single', 'imagePath': 'lib/assets/categories.png'},
      {'title': 'Double', 'imagePath': 'lib/assets/categories.png'},
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

  Widget _categoryCard(String title, String imagePath) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPGListScreen(
                filters: {
                  'gender': _gender ?? '',
                  'sharing': _sharing ?? '',
                  'fooding': _fooding ?? '',
                  'foodtype': _foodtype ?? '',
                  'ac': _ac == 'Available',
                  'cctv': _cctv == 'Available',
                  'wifi': _wifi == 'Available',
                  'parking': _parking == 'Available',
                  'laundary': _laundary == 'Available',
                  'profession': _profession ?? '',
                },
              ),
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