import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchPGData();
  }

  Future<void> _fetchPGData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).get();
    if (doc.exists) {
      setState(() {
        pgData = doc.data() as Map<String, dynamic>?;
        overallRating = _calculateOverallRating(pgData?['reviews'] ?? []);
      });
    }
  }

  double _calculateOverallRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }
    return totalRating / reviews.length;
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
            if (selectedSectionIndex == 0)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        IconTextWidget(icon: Icons.bed, text: '3 Beds'),
                        Spacer(),
                        IconTextWidget(icon: Icons.bathtub, text: '1 Bath'),
                        Spacer(),
                        IconTextWidget(icon: Icons.ac_unit, text: '1 AC'),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Location', style: TextStyle(color: Colors.black, fontSize: 20)),
                    SizedBox(height: 10),
                    /*FlutterMap(
                      options: MapOptions(
                        center: LatLng(pgData!['location']['latitude'], pgData!['location']['longitude']),
                        zoom: 15.0,
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: LatLng(pgData!['location']['latitude'], pgData!['location']['longitude']),
                              builder: (ctx) => Container(
                                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            // Gallery Section
            if (selectedSectionIndex == 1)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pgData!['images'].map<Widget>((image) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.network(image),
                    );
                  }).toList(),
                ),
              ),
            // Review Section
            if (selectedSectionIndex == 2)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBar.builder(
                      initialRating: 3,
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
                        print(rating);
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Reviews:', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (pgData!['reviews'] ?? []).map<Widget>((review) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('${review['review']} - ${review['rating']}⭐'),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Leave a review',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality to submit review
                      },
                      child: Text('Submit Review'),
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
              onPressed: () {
                // Add functionality for the button here
              },
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
        width: MediaQuery.of(context).size.width * 0.25, // Adjust width as needed
        height: 30, // Adjust height as needed
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: selectedSectionIndex == index ? Colors.blue : Colors.grey,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}
