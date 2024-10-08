import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Pg extends StatefulWidget {
  final String pgId;

  Pg({required this.pgId});

  @override
  _PgState createState() => _PgState();
} //late final MapController _mapController;

class _PgState extends State<Pg> {
  int selectedSectionIndex = 0;
  Map<String, dynamic>? pgData;
  double overallRating = 0.0;
  int reviewCount = 0;
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 3.0; // Use dynamic rating
  List<String>? pgImages ;
  @override
  void initState() {
    super.initState();
    _fetchPGData();
    //_mapController = MapController();
  }

  Future<void> _fetchPGData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).get();
      pgImages = await fetchAllPGImages();
      if (doc.exists) {
        setState(() {
          pgData = doc.data() as Map<String, dynamic>?;
        });
        print('PG Data fetched: $pgData'); // Debug print
        _calculateOverallRating(); // Calculate rating after fetching data
      } else {
        print('No PG document found for ID: ${widget.pgId}'); // Debug print
      }
    } catch (e) {
      print('Error fetching PG data: $e');
    }
  }

  Future<List<String>> fetchAllPGImages() async {
    List<String> allImages = [];

    // Fetch all documents from the 'pg_details' collection
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('pg_details').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Add the thumbnail image if it exists
      if (data['thumbnail'] != null && data['thumbnail'].isNotEmpty) {
        allImages.add(data['thumbnail']);
      }

      // Check if 'sharing_details' exists and is a list
      if (data['sharing_details'] != null && data['sharing_details'] is List) {
        for (var sharingDetail in data['sharing_details']) {
          if (sharingDetail['images'] != null && sharingDetail['images'] is List) {
            allImages.addAll(List<String>.from(sharingDetail['images']));
          }
        }
      }

      // Add other_pics images if they exist
      if (data['other_pics'] != null && data['other_pics'] is List) {
        allImages.addAll(List<String>.from(data['other_pics']));
      }
    }

    return allImages;
  }

  /*Future<Map<String, double>> getCoordinatesFromLocation(String locationName) async {
    final apiKey = 'ExmGgEXRZ4oFbM5bA3Nb';
    final url = 'https://api.maptiler.com/geocoding/$locationName.json?key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      return {
        'longitude': coordinates[0],
        'latitude': coordinates[1],
      };
    } else {
      throw Exception('Failed to get coordinates');
    }
  }*/

  Future<void> _calculateOverallRating() async {
    try {
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).collection('reviews').get();
      print('Reviews fetched: ${reviewSnapshot.docs.length}'); // Debug print
      if (reviewSnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        int count = reviewSnapshot.docs.length;
        for (var doc in reviewSnapshot.docs) {
          final reviewData = doc.data() as Map<String, dynamic>;
          totalRating += reviewData['rating'] ?? 0.0;
        }
        setState(() {
          overallRating = count > 0 ? totalRating / count : 0.0;
          reviewCount = count;
        });
        print('Overall Rating calculated: $overallRating, Review Count: $reviewCount'); // Debug print
      } else {
        setState(() {
          overallRating = 0.0;
          reviewCount = 0;
        });
        print('No reviews found'); // Debug print
      }
    } catch (e) {
      print('Error calculating overall rating: $e');
    }
  }


  Future<void> _bookNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case when no user is logged in
      print('No user is currently logged in');
      return;
    }

    final userId = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();
    final userData = userSnapshot.data() as Map<String, dynamic>?;

    if (userData == null) {
      print('User data not found');
      return;
    }

    final ownerId = pgData!['ownerId']; // Assuming PG document contains 'ownerId'
    final ownerDoc = FirebaseFirestore.instance.collection('pg_owners').doc(ownerId);
    final ownerSnapshot = await ownerDoc.get();
    final ownerData = ownerSnapshot.data() as Map<String, dynamic>?;

    if (ownerData == null) {
      print('Owner data not found');
      return;
    }

    final booking = {
      'uid': userId,
      'customerName': userData['name'],
      'customerPhone': userData['phone'],
      'pgName': pgData!['name'],
      'location': pgData!['location'],
      /*'price': pgData!['price'],*/
      'ownerName': ownerData['name'],
      'ownerPhone': ownerData['phone'],
      'timestamp': FieldValue.serverTimestamp(),
      'pgId':widget.pgId,
    };

    try {
      await FirebaseFirestore.instance.collection('bookings').add(booking);
      print('Booking submitted: $booking'); // Debug print
      _showBookingConfirmation();
    } catch (e) {
      print('Error submitting booking: $e');
    }
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Confirmed'),
          content: Text('Appointment booked. You will be contacted soon.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, double>> getCoordinatesFromLocation(String locationName) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$locationName&format=json&limit=1';

    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();

    final responseData = await response.transform(utf8.decoder).join();
    final data = json.decode(responseData);

    if (data.isNotEmpty) {
      final coordinates = data[0];
      return {
        'longitude': double.parse(coordinates['lon']),
        'latitude': double.parse(coordinates['lat']),
      };
    } else {
      throw Exception('No coordinates found for the location');
    }
  }
  /*Future<Map<String, double>> getCoordinatesFromLocation(String locationName) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$locationName&format=json&limit=1';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final coordinates = data[0];
        return {
          'longitude': double.parse(coordinates['lon']),
          'latitude': double.parse(coordinates['lat']),
        };
      } else {
        throw Exception('No coordinates found for the location');
      }
    } else {
      throw Exception('Failed to get coordinates');
    }
  }*/

  Future<void> _submitReview(double rating, String reviewText) async {
    final review = {
      'rating': rating,
      'review': reviewText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).collection('reviews').add(review);
      print('Review submitted: $review'); // Debug print
      await _fetchPGData(); // Refresh data after submitting
      _reviewController.clear(); // Clear the text field after submission
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String locationName = pgData!['location']??'No location Provided';
    locationName=locationName+" ,Kolkata , West Bengal, India";
    if (pgData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pgData!['thumbnail'].isNotEmpty
                ? Image.network(pgData!['thumbnail'][0], height: 500, width: MediaQuery.of(context).size.width, fit: BoxFit.cover)
                : SizedBox(height: 500),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 186, 224, 255),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  '10% Off',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 140, 255),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pgData!['name'] ?? 'PG Name',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    pgData!['summary'] ?? 'PG Summary',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildSectionItem(0, 'About'),
                  buildSectionItem(1, 'Gallery'),
                  buildSectionItem(2, 'Review'),
                ],
              ),
            ),
            // About Section
            if (selectedSectionIndex == 0)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sharing Details",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 8,),
                    for (var detail in (pgData!['sharing_details'] as List<dynamic>))
                      if (detail['selected'] == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Row for Title, Price, and Vacant Beds
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Title
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      detail['title'] ?? 'No Title',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue
                                      ),
                                    ),
                                  ),
                                  // Vacant Beds
                                  Row(
                                    children: [
                                      Icon(Icons.bed, color: Colors.blue, size: 20), // Vacant beds icon
                                      SizedBox(width: 5),
                                      Text('x ${detail['vacantBeds'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  // Price
                                  Row(
                                    children: [
                                      Icon(Icons.currency_rupee_outlined, color: Colors.blue, size: 20), // Price icon
                                      SizedBox(width: 5),
                                      Text('${detail['price'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5), // Space between rows
                              // Second Row for Furnishing
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.chair, color: Colors.blue, size: 20), // Furnishing icon
                                  SizedBox(width: 5),
                                  Text('${detail['furnishing'] ?? 'Not Specified'}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                    /*for (var detail in (pgData!['sharing_details'] as List<dynamic>))
                      if (detail['selected'] == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Title
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  detail['title'] ?? 'No Title',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.bed,color: Colors.blue ,size: 20), // Vacant beds icon
                                  SizedBox(width: 5),
                                  Text('x ${detail['vacantBeds'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee_outlined, color: Colors.blue, size: 20), // Price icon
                                  SizedBox(width: 5),
                                  Text('${detail['price'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              // Vacant Beds

                            ],
                          ),
                        ),*/

                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.bed,
                          text: pgData!['sharing_details'] == 'Single'
                              ? '1 Bed'
                              : pgData!['sharing'] == 'Double'
                              ? '2 Beds'
                              : '3 Beds',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.chair,
                          text: pgData!['furnishing'] ?? 'Unfurnished',
                        ),
                      ],
                    ),*/
                    SizedBox(height: 10), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.wc,
                          text: pgData!['gender'] ?? 'Both Genders',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.videocam,
                          text: pgData!['cctv'] ?? 'CCTV Not Available',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (pgData!['ac'] != null)
                          Row(
                            children: [
                              Icon(Icons.ac_unit, color: Colors.blue, size: 20),
                              SizedBox(width: 5),
                              Text('${pgData!['ac'] ?? 'AC Not Available'}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        if (pgData!['fooding'] != null)
                          Row(
                            children: [
                              Icon(Icons.fastfood, color: Colors.blue, size: 20),
                              SizedBox(width: 5),
                              Text('${pgData!['fooding'] ?? 'Food Not Included'}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (pgData!['foodtype'] != null)
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: Colors.blue, size: 20),
                              SizedBox(width: 5),
                              Text('${pgData!['foodtype'] ?? 'Food Type Not Available'}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    if (pgData!['elecbill'] != null)
                      Row(
                        children: [
                          Icon(Icons.electric_bolt, color: Colors.blue, size: 20),
                          SizedBox(width: 5),
                          Text('${pgData!['elecbill'] ?? 'Electric Bill Not Included'}', style: TextStyle(fontSize: 16)),
                          if (pgData!['elecbill'] == 'Not Included')
                            Text(' (Bill Amount: ${pgData!['billAmount'] ?? 'N/A'})', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        *//*IconTextWidget(
                          icon: Icons.electrical_services,
                          text: pgData!['elecbill'] ?? 'Electric Bill Not Included',
                        ),*//*
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.fastfood,
                          text: pgData!['fooding'] ?? 'Food Not Included',
                        ),
                      ],
                    ),*/
                    //SizedBox(height: 10), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /*IconTextWidget(
                          icon: Icons.dining,
                          text: pgData!['foodtype'] ?? 'Food Type Not Available',
                        ),*/
                        //SizedBox(width: 10), // Reduced space between keywords
                        /*IconTextWidget(
                          icon: Icons.ac_unit,
                          text: pgData!['ac'] ?? 'AC Not Available',
                        ),*/
                      ],
                    ),
                    SizedBox(height: 10), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.local_laundry_service,
                          text: pgData!['laundary'] ?? 'Laundry Not Available',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.local_parking,
                          text: pgData!['parking'] ?? 'Parking Not Available',
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.work,
                          text: pgData!['profession'] ?? 'Profession Not Specified',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.wifi,
                          text: pgData!['wifi'] ?? 'WiFi Not Available',
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Location', style: TextStyle(color: Colors.black, fontSize: 20)),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey, size: 20), // Location pin icon
                            SizedBox(width: 5),
                            Text(pgData!['location'] ?? 'Location not available', style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                        /*Text(pgData!['location'] ?? 'Location not available', style: TextStyle(color: Colors.grey, fontSize: 18)),*/
                      ],
                    ),
                    SizedBox(height: 20),

                    // FutureBuilder to fetch coordinates and display the map
                    FutureBuilder<Map<String, double>>(
                      future: getCoordinatesFromLocation(locationName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator()); // Loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // Error message
                        } else if (snapshot.hasData) {
                          final latitude = snapshot.data!['latitude'];
                          final longitude = snapshot.data!['longitude'];

                          print(latitude);
                          print(longitude);
                          return Container(
                            height: 300,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(latitude!, longitude!),
                                initialZoom: 17.5,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: [
                                        LatLng(latitude + 0.001, longitude + 0.001),
                                        LatLng(latitude + 0.001, longitude - 0.001),
                                        LatLng(latitude - 0.001, longitude - 0.001),
                                        LatLng(latitude - 0.001, longitude + 0.001),
                                      ],
                                      color: Colors.blue.withOpacity(0.3),
                                      borderStrokeWidth: 2.0,
                                      borderColor: Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return Text('No data available');
                      },
                    ),
                    /*FutureBuilder<Map<String, double>>(
                      future: getCoordinatesFromLocation(locationName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator()); // Loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // Error message
                        } else if (snapshot.hasData) {
                          final latitude = snapshot.data!['latitude'];
                          final longitude = snapshot.data!['longitude'];
                          print("-----------------------------------------------");
                          print(latitude);
                          print(longitude);
                          return Container(
                            height: 300,
                            child: FlutterMap(
                              //mapController: _mapController,
                              options: MapOptions(
                                // You may remove center and zoom if they cause issues.
                                initialCenter: LatLng(latitude!, longitude!),
                                initialZoom: 17.4,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://api.maptiler.com/maps/basic/{z}/{x}/{y}.png?key=ExmGgEXRZ4oFbM5bA3Nb",
                                  additionalOptions: {
                                    'key': 'ExmGgEXRZ4oFbM5bA3Nb',
                                  },
                                ),
                                PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: [
                                        LatLng(latitude! + 0.001, longitude! + 0.001),
                                        LatLng(latitude! + 0.001, longitude! - 0.001),
                                        LatLng(latitude! - 0.001, longitude! - 0.001),
                                        LatLng(latitude! - 0.001, longitude! + 0.001),
                                      ],
                                      color: Colors.blue.withOpacity(0.3),
                                      borderStrokeWidth: 2.0,
                                      borderColor: Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return Text('No data available');
                      },
                    ),*/
                  ],
                ),
              ),
            // Gallery Section
            if (selectedSectionIndex == 1)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Builder(
                      builder: (context) {
                        // Filter the sharing_details list to get all selected entries
                        final selectedDetails = pgData!['sharing_details']
                            .where((detail) => detail['selected'] == true)
                            .toList();

                        // Print the selected details to debug
                        print('Selected Details: $selectedDetails');

                        // If there are no selected details, return an empty container
                        if (selectedDetails.isEmpty) {
                          return Center(child: Text('No images to display.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this ListView
                          itemCount: selectedDetails.length,
                          itemBuilder: (context, index) {
                            final detail = selectedDetails[index];
                            final title = detail['title'];
                            final images = detail['images'] as List;

                            // If there are no images, display a message instead of GridView
                            if (images.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.0), // Spacing before the message
                                    Text(
                                      'No images available for $title.',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 20.0), // Spacing between sections
                                  ],
                                ),
                              );
                            }

                            // If there are images, display the GridView
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Number of columns
                                    crossAxisSpacing: 8.0, // Horizontal spacing between images
                                    mainAxisSpacing: 8.0, // Vertical spacing between images
                                    childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                                  ),
                                  itemCount: images.length,
                                  shrinkWrap: true, // Allows the GridView to take up only the necessary space
                                  physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                                  itemBuilder: (context, imageIndex) {
                                    final imageUrl = images[imageIndex];

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.0), // Spacing between sections
                              ],
                            );
                          },
                        );

                        /*if (selectedDetails.isEmpty) {
                          return Center(child: Text('No images to display.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this ListView
                          itemCount: selectedDetails.length,
                          itemBuilder: (context, index) {
                            final detail = selectedDetails[index];
                            final title = detail['title'];
                            final images = detail['images'] as List;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title for the current group of images
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // GridView for the images
                                GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Number of columns
                                    crossAxisSpacing: 8.0, // Horizontal spacing between images
                                    mainAxisSpacing: 8.0, // Vertical spacing between images
                                    childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                                  ),
                                  itemCount: images.length,
                                  shrinkWrap: true, // Allows the GridView to take up only the necessary space
                                  physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                                  itemBuilder: (context, imageIndex) {
                                    final imageUrl = images[imageIndex];

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.0), // Spacing between sections
                              ],
                            );
                          },
                        );*/
                      },
                    ),
                    SizedBox(height: 10,),
                    if (pgData != null && pgData!['other_pics'] != null && pgData!['other_pics'].isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Other Pictures',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 10), // Add some spacing before the GridView
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 8.0, // Horizontal spacing between images
                          mainAxisSpacing: 8.0, // Vertical spacing between images
                          childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                        ),
                        itemCount: pgData!['other_pics'].length,
                        shrinkWrap: true, // Allows the GridView to take up only the necessary space
                        physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                        itemBuilder: (context, imageIndex) {
                          final imageUrl = pgData!['other_pics'][imageIndex];

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ] else SizedBox.shrink() // This will render nothing if there are no other_pics
                    /*SizedBox(height: 10,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Other Pictures',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 8.0, // Horizontal spacing between images
                        mainAxisSpacing: 8.0, // Vertical spacing between images
                        childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                      ),
                      itemCount: pgData!['other_pics'].length,
                      shrinkWrap: true, // Allows the GridView to take up only the necessary space
                      physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                      itemBuilder: (context, imageIndex) {
                        final imageUrl = pgData!['other_pics'][imageIndex];

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),*/
                  ],
                ),
              ),


            /*if (selectedSectionIndex == 1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Builder(
                builder: (context) {
                // Filter the sharing_details list to get all selected entries
                final selectedDetails = pgData!['sharing_details']
                    .where((detail) => detail['selected'] == true)
                    .toList();

                // Print the selected details to debug
                print('Selected Details: $selectedDetails');

                // Extract all images from the selected details
                final allImages = selectedDetails
                    .expand((detail) => detail['images'] as List)
                    .toList();

                // Print the list of all images to debug
                print('All Images: $allImages');

                // If there are no images, return an empty container
                if (allImages.isEmpty) {
                return Center(child: Text('No images to display.'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 8.0, // Horizontal spacing between images
                    mainAxisSpacing: 8.0, // Vertical spacing between images
                    childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                  ),
                  itemCount: allImages.length,
                  shrinkWrap: true, // Allows the GridView to take up only the necessary space
                  physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                  itemBuilder: (context, index) {
                  // Determine the current image to display based on the index
                    final imageUrl = allImages[index];

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  );
                },
              ),
            ),
*/

            /*Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 8.0, // Horizontal spacing between images
                    mainAxisSpacing: 8.0, // Vertical spacing between images
                    childAspectRatio: 1.0, // Aspect ratio of each item (1.0 makes it square)
                  ),
                  itemCount: pgData!['images'].length,
                  shrinkWrap: true, // Allows the GridView to take up only the necessary space
                  physics: NeverScrollableScrollPhysics(), // Prevents scrolling in this GridView
                  itemBuilder: (context, index) {
                    final imageUrl = pgData!['images'][index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),*/

            // Review Section
            if (selectedSectionIndex == 2)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Rating: ${overallRating.toStringAsFixed(1)}⭐ (${reviewCount} reviews)', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Reviews:', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No reviews yet.');
                        }
                        final reviews = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reviews.map<Widget>((doc) {
                            final reviewData = doc.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('${reviewData['review']} - ${reviewData['rating']}⭐'),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: _selectedRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _selectedRating = rating; // Update selected rating
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Leave a review',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final reviewText = _reviewController.text;
                        final rating = _selectedRating; // Use dynamic rating
                        if (reviewText.isNotEmpty) {
                          _submitReview(rating, reviewText);
                        }
                      },
                      child: Text('Submit Review'),
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white;
                            }
                            return Color(0xff0094FF);
                          }),
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Color(0xff0094FF);
                            }
                            return Colors.white;
                          }),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side:  BorderSide(color: Color(0xff0094FF)),))),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            TextButton(
              onPressed: () {},
              child: Text(
                '₹${_getPriceBasedOnSharing(pgData!['sharing_details'])}/month',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Are you sure you want to book this PG?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Dismiss and return false
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Dismiss and return true
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  _bookNow(); // Call the booking function if the user confirms
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
              child: Text(
                'Book Now',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget buildSectionItem(int index, String title) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedSectionIndex = index;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedSectionIndex == index ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }


  double? _getPriceBasedOnSharing(List<dynamic> sharingDetail) {
    double? lowestPrice;
    // Find the lowest price in the sharingOptions array
    for (var option in sharingDetail) {
      String priceStr = option['price'] ?? '';
      double price = double.tryParse(priceStr) ?? double.infinity;

      if (lowestPrice == null || price < lowestPrice) {
        lowestPrice = price;
      }
    }
    return lowestPrice;
  }
}

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  IconTextWidget({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}