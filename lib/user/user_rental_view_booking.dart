import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentelProductBookingListScreen extends StatefulWidget {
  const RentelProductBookingListScreen({Key? key}) : super(key: key);

  @override
  _RentelProductBookingListScreenState createState() =>
      _RentelProductBookingListScreenState();
}

class _RentelProductBookingListScreenState
    extends State<RentelProductBookingListScreen> {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple
              Color.fromARGB(255, 162, 213, 255), // Blue
              Colors.white, // White
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50), // Space for status bar

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Rental Bookings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: userId == null
                  ? Center(
                      child: Text(
                        'Please log in to view bookings.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No bookings found.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }

                        final bookings = snapshot.data!.docs;

                        return RefreshIndicator(
                          onRefresh: _refreshBookings,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index].data()
                                  as Map<String, dynamic>;
                              return BookingCard(booking: booking);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.blueAccent, size: 20),
              SizedBox(width: 5),
              Text(
                booking['product'] ?? 'Unnamed Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 16),
              SizedBox(width: 5),
              Text(
                'From: ${booking['bookedDate']}',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.event, color: Colors.grey, size: 16),
              SizedBox(width: 5),
              Text(
                'To: ${booking['bookedToDate']}',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color:
                    booking['status'] == 'Booked' ? Colors.green : Colors.red,
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                'Status: ${booking['status']}',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      booking['status'] == 'Booked' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
