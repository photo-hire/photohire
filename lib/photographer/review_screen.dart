import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final String studioId;
  const ReviewScreen({super.key, required this.studioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Studio Reviews',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('studioId', isEqualTo: studioId)
            .orderBy('timestamp', descending: true) // Requires Firestore Index
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          var reviews = snapshot.data?.docs ?? [];
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                "No reviews yet!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];

              // Ensure fields exist before using them
              String userName = review['userName'] ?? "Unknown";
              String reviewText = review['reviewText'] ?? "No review text";
              double rating = (review['rating'] is int)
                  ? (review['rating'] as int).toDouble()
                  : (review['rating'] ?? 0.0).toDouble();

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                color: Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    reviewText,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(
                        '$rating⭐',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
