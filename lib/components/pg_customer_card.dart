import 'package:flutter/material.dart';

class PGCard extends StatelessWidget {
  final String name;
  final String location; // Add location parameter
  final List<String> imageUrls;
  final double price; // Add price parameter
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PGCard({
    required this.name,
    required this.location, // Add location to the constructor
    required this.imageUrls,
    required this.price, // Add price to the constructor
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Row(
                    children: List.generate(
                      imageUrls.length,
                          (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${price.toStringAsFixed(0)} \nper month", // Display the price without decimal points
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0094FF),
                  ),
                ),
                /*Text(
                  "\₹$price \nper month", // Display the price dynamically
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0094FF),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
