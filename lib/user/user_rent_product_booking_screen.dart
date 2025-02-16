import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentelProductBookingListScreen extends StatefulWidget {
  const RentelProductBookingListScreen({Key? key}) : super(key: key);

  @override
  _RentelProductBookingListScreenState createState() => _RentelProductBookingListScreenState();
}

class _RentelProductBookingListScreenState extends State<RentelProductBookingListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _refreshBookings() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String? userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view bookings.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No bookings found.'));
                }

                final bookings = snapshot.data!.docs;

                return RefreshIndicator(
                  onRefresh: _refreshBookings,
                  child: ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index].data() as Map<String, dynamic>;
                      return BookingCard(booking: booking);
                    },
                  ),
                );
              },
            ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['product'] ?? 'Unnamed Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Booked From: ${booking['bookedDate']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Booked To: ${booking['bookedToDate']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Status: ${booking['status']}',
              style: TextStyle(
                fontSize: 14,
                color: booking['status'] == 'Booked' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}