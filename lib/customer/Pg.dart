import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Pg extends StatefulWidget {
  final String pgId;

  Pg({required this.pgId});

  @override
  _PgState createState() => _PgState();
}

class _PgState extends State<Pg> {
  int selectedSectionIndex = 0;
  Map<String, dynamic>? pgData;
  double overallRating = 0.0;
  int reviewCount = 0;
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 3.0; // Use dynamic rating

  @override
  void initState() {
    super.initState();
    _fetchPGData();
  }

  Future<void> _fetchPGData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).get();
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
      'price': pgData!['price'],
      'ownerName': ownerData['name'],
      'ownerPhone': ownerData['phone'],
      'timestamp': FieldValue.serverTimestamp(),
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
            pgData!['images'].isNotEmpty
                ? Image.network(pgData!['images'][0], height: 500, width: MediaQuery.of(context).size.width, fit: BoxFit.cover)
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
            // About Section
            if (selectedSectionIndex == 0)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.bed,
                          text: pgData!['sharing'] == 'Single'
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
                    ),
                    SizedBox(height: 20), // Space between rows
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
                    SizedBox(height: 20), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.electrical_services,
                          text: pgData!['elecbill'] ?? 'Electric Bill Not Included',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.fastfood,
                          text: pgData!['fooding'] ?? 'Food Not Included',
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // Space between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.dining,
                          text: pgData!['foodtype'] ?? 'Food Type Not Available',
                        ),
                        SizedBox(width: 10), // Reduced space between keywords
                        IconTextWidget(
                          icon: Icons.ac_unit,
                          text: pgData!['ac'] ?? 'AC Not Available',
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // Space between rows
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
                    SizedBox(height: 20), // Space between rows
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
                  ],
                ),
              ),
            // Gallery Section
            if (selectedSectionIndex == 1)
              Padding(
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
              ),

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
                '₹${pgData!['price']}/month',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: _bookNow,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
              child: Text(
                'Book Now',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
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