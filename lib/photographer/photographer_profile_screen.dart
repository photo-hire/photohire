import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:photohire/photographer/photographer_edit_profile.dart';
import 'package:photohire/photographer/photographer_orders_screen.dart';
import 'package:photohire/photographer/photographers_bookings_list_screen.dart';
import 'package:photohire/photographer/review_screen.dart';
import 'package:photohire/user/change_password_screen.dart';

class PhotographerProfileScreen extends StatefulWidget {
  const PhotographerProfileScreen({super.key});

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen> {
  String? _companyLogoUrl;
  String? _name;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('photgrapher')
        .doc(userId)
        .snapshots();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Profile not found"));
          }

          var userData = snapshot.data!.data();
          _name = userData?['company'] ?? "Studio Name";
          _companyLogoUrl = userData?['companyLogo'];

          return Stack(
            children: [
              // Background Image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("asset/image/bg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: 60),

                  // Profile Title & Logout Icon
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.logout, color: Colors.white, size: 28),
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Profile Picture
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _companyLogoUrl != null &&
                                _companyLogoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _companyLogoUrl!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Company Name
                  Text(
                    _name!,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Profile Options
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Overview",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildProfileOption(Icons.person, "My Profile", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPhotographerProfileScreen(),
                                  ));
                            }),
                            SizedBox(height: 15),
                            _buildProfileOption(
                                Icons.book_online, "My Bookings", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhotographerBookingsListScreen()),
                              );
                            }),
                            SizedBox(height: 15),
                            _buildProfileOption(Icons.shopping_bag, "My Orders",
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhotographerOrdersScreen()),
                              );
                            }),
                            SizedBox(height: 15),
                            _buildProfileOption(Icons.reviews, "View Reviews",
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                    studioId:
                                        userId, // Pass the logged-in photographer's ID
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 15),
                            _buildProfileOption(Icons.lock, "Change Password",
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen(),
                                  ));
                            }),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
