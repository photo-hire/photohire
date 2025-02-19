import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/admin/admin_store_management_screen.dart';
import 'package:photohire/admin/bookingview';
import 'package:photohire/admin/reviewscreen.dart';
import 'package:photohire/admin/studio_management_screen.dart';
// import 'package:photohire/admin/reviews_screen.dart'; // Import the Reviews Screen

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "asset/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudioManagementScreen(),
                            ));
                      },
                      child: Text(
                        "Studio management",
                        style: TextStyle(
                            color: Color(0xff03399E),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ))),
              SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreManagementScreen(),
                            ));
                      },
                      child: Text(
                        "Store management",
                        style: TextStyle(
                            color: Color(0xff03399E),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ))),
              SizedBox(height: 20),
              // New View Reviews Button
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Custom Button Color
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewsScreen(),
                            ));
                      },
                      child: Text(
                        "View Reviews",
                        style: TextStyle(
                            color: Color(0xff03399E),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ))),
              SizedBox(height: 20),
              // New View Reviews Button
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Custom Button Color
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhotographerBookingsScreen(),
                            ));
                      },
                      child: Text(
                        "View Booking",
                        style: TextStyle(
                            color: Color(0xff03399E),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ))),
              SizedBox(
                height: 100.h,
              ),
            ],
          ),
          Positioned(
              bottom: 0.h,
              left: 50.w,
              child: Image.asset(
                "asset/image/choose.png",
                height: 300.h,
                width: 300.w,
              )),
        ],
      ),
    );
  }
}
