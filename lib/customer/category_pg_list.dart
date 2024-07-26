import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Pg.dart';
import '../components/pg_card.dart'; // Import the PGCard

class CategoryPGListScreen extends StatefulWidget {
  final Map<String, dynamic> filters; // Updated to accept various filters

  const CategoryPGListScreen({required this.filters, Key? key}) : super(key: key);

  @override
  _CategoryPGListScreenState createState() => _CategoryPGListScreenState();
}

class _CategoryPGListScreenState extends State<CategoryPGListScreen> {
  List<Map<String, dynamic>> pgList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPGsByCategory();
  }

  Future<void> _fetchPGsByCategory() async {
    try {
      Query query = FirebaseFirestore.instance.collection('pgs');

      // Apply filters based on the provided filters map
      widget.filters.forEach((key, value) {
        if (value is String) {
          query = query.where(key, isEqualTo: value);
        } else if (value is bool) {
          query = query.where(key, isEqualTo: value);
        }
      });

      QuerySnapshot snapshot = await query.get();
      List<DocumentSnapshot> docs = snapshot.docs;
      List<Map<String, dynamic>> pgs = [];

      for (var doc in docs) {
        Map<String, dynamic> pgData = doc.data() as Map<String, dynamic>;
        List<String> images = List<String>.from(pgData['images']);
        if (images.isNotEmpty) {
          pgs.add({
            'id': doc.id,
            'name': pgData['name'],
            'summary': pgData['summary'],
            'image': images[0], // Use the first image or select randomly
          });
        }
      }

      setState(() {
        pgList = pgs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching PGs by category: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PG List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pgList.length,
        itemBuilder: (context, index) {
          final pg = pgList[index];
          return HotelCard(
            name: pg['name'],
            summary: pg['summary'],
            imageUrls: [pg['image']],
            onEdit: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }
}
