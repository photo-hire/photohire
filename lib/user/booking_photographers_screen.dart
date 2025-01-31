import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/user/user_booking_form.dart';

class UserBookingScreen extends StatelessWidget {
  final Map<String, dynamic> studioDetails;
  final String studioId;

  const UserBookingScreen({super.key, required this.studioDetails, required this.studioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Book ${studioDetails['company']}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
         decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(11),
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white, // White (Bottom)
            ],
          ),
        ),
        child: BookingForm(studioDetails: studioDetails, studioId: studioId)),
    );
  }
}
