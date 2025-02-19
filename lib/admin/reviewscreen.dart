import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatelessWidget {
  final CollectionReference reviewsCollection =
      FirebaseFirestore.instance.collection('reviews');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews')),
      body: StreamBuilder<QuerySnapshot>(
        stream: reviewsCollection.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Reviews Found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var reviewData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String reviewText = reviewData['reviewText'] ?? 'No Review';
              String reviewerName = reviewData['reviewerName'] ?? 'Anonymous';
              double rating = (reviewData['rating'] ?? 0).toDouble();
              DateTime? date = (reviewData['date'] as Timestamp?)?.toDate();
              String formattedDate = date != null
                  ? DateFormat.yMMMd().format(date)
                  : 'Unknown Date';

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(reviewerName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text('Rating: ⭐ $rating/5'),
                      Text(reviewText, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Text(formattedDate,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
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
