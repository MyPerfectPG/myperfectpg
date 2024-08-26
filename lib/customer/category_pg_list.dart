import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/pg_customer_card.dart';
import 'Pg.dart';

class CategoryPGListScreen extends StatefulWidget {
  final String category;

  const CategoryPGListScreen({required this.category, Key? key}) : super(key: key);

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

      // Apply category-based filtering
      switch (widget.category) {
        case 'Boys':
          query = query.where('gender', whereIn: ['Boys', 'Both']);
          break;
        case 'Girls':
          query = query.where('gender', whereIn: ['Girls', 'Both']);
          break;
        case 'Both':
          query = query.where('gender', whereIn: ['Both']);
          break;
        case 'AC':
          QuerySnapshot snapshot = await query.get();
          List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
            final List<String> acList = List<String>.from(doc['ac']);
            return acList.contains('Available');
          }).toList();

          _populatePGList(filteredDocs);
          return;
        case 'Non AC':
          QuerySnapshot snapshot = await query.get();
          List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
            final List<String> acList = List<String>.from(doc['ac']);
            return acList.contains('Not Available');
          }).toList();

          _populatePGList(filteredDocs);
          return;
        case 'Single':
        // Custom filter for Single sharing with title and selected field checks
          QuerySnapshot snapshot = await query.get();
          List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
            final sharingDetail = doc['sharing_details'];
            return sharingDetail.any((detail) =>
            detail['title'] == 'Single' && detail['selected'] == true);
          }).toList();
          _populatePGList(filteredDocs);
          return; // Skip the general fetch below
        case 'Double':
          QuerySnapshot snapshot = await query.get();
          List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
            final sharingDetail = doc['sharing_details'];
            return sharingDetail.any((detail) =>
            detail['title'] == 'Double' && detail['selected'] == true);
          }).toList();
          _populatePGList(filteredDocs);
          return;
        case 'Triple':
          QuerySnapshot snapshot = await query.get();
          List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
            final sharingDetail = doc['sharing_details'];
            return sharingDetail.any((detail) =>
            detail['title'] == 'Triple' && detail['selected'] == true);
          }).toList();

          _populatePGList(filteredDocs);
          return;
        default:
        // If no category matches, return all PGs
          break;
      }

      QuerySnapshot snapshot = await query.get();
      List<DocumentSnapshot> docs = snapshot.docs;
      _populatePGList(docs);
    } catch (e) {
      print("Error fetching PGs by category: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _populatePGList(List<DocumentSnapshot> docs) {
    List<Map<String, dynamic>> pgs = [];

    for (var doc in docs) {
      Map<String, dynamic> pgData = doc.data() as Map<String, dynamic>;
      List<String> images = List<String>.from(pgData['thumbnail']);
      double? lowestPrice;

      // Extract the sharingOptions array
      List<dynamic> sharingOptions = pgData['sharing_details'];

      // Find the lowest price in the sharingOptions array
      for (var option in sharingOptions) {
        String priceStr = option['price'] ?? '';
        double price = double.tryParse(priceStr) ?? double.infinity;

        if (lowestPrice == null || price < lowestPrice) {
          lowestPrice = price;
        }
      }

      // Check if images list is not empty
      if (images.isNotEmpty) {
        pgs.add({
          'id': doc.id,
          'name': pgData['name'],
          'location': pgData['location'], // Fetch the location
          'image': images.first, // Safely access the first image
          'price': lowestPrice, // Cast price to double*/
        });
      }
    }

    setState(() {
      pgList = pgs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} PGs', style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xff0094FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pgList.isEmpty
          ? Center(child: Text('No PGs available for this category.'))
          : ListView.builder(
        itemCount: pgList.length,
        itemBuilder: (context, index) {
          final pg = pgList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Pg(pgId: pg['id']),
                ),
              );
            },
            child: PGCard(
              name: pg['name'],
              location: pg['location'], // Pass the location to PGCard
              imageUrls: [pg['image']],
              price: pg['price'], // Pass the price to PGCard
              onEdit: () {},
              onDelete: () {},
            ),
          );
        },
      ),
    );
  }
}
