import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PhotographerBookingsListScreen extends StatelessWidget {
  const PhotographerBookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('photographerbookings')
              .where('studio', isEqualTo: currentUserId)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No bookings found",
                  style:
                      GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
                ),
              );
            }

            var bookings = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index].data() as Map<String, dynamic>;
                final date = booking['date'] ?? 'No Date';
                final name = booking['name'] ?? 'No Name';
                final notes = booking['notes'] ?? 'No Notes';
                final phone = booking['phone'] ?? 'No Phone';
                final time = booking['time'] ?? 'No Time';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        Divider(color: Colors.grey.shade300),
                        SizedBox(height: 5.h),
                        _buildInfoRow(
                            FontAwesomeIcons.calendarDay, 'Date', date),
                        _buildInfoRow(FontAwesomeIcons.clock, 'Time', time),
                        _buildInfoRow(FontAwesomeIcons.phone, 'Phone', phone),
                        _buildInfoRow(
                            FontAwesomeIcons.stickyNote, 'Notes', notes),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.blue[800]),
          SizedBox(width: 10.w),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
