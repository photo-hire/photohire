import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotographerBookingsListScreen extends StatelessWidget {
  const PhotographerBookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('photographerbookings')
            .where('studio', isEqualTo: currentUserId) // Filter by current user's UID
            .orderBy('date', descending: true) // Sort by date
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue[900],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No bookings found",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            );
          }

          var bookings = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final date = booking['date'] ?? 'No Date';
              final name = booking['name'] ?? 'No Name';
              final notes = booking['notes'] ?? 'No Notes';
              final phone = booking['phone'] ?? 'No Phone';
              final time = booking['time'] ?? 'No Time';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking for: $name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Date: $date',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Time: $time',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Phone: $phone',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Notes: $notes',
                        style: TextStyle(fontSize: 14.sp),
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