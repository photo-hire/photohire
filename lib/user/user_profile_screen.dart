import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/user/change_password_screen.dart';
import 'package:photohire/user/user_edit_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photohire/user/user_orders.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _name = '';
  String _phone = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _email = userDoc['email'] ?? 'No email';
          _name = userDoc['name'] ?? 'No name';
          _phone = userDoc['phone'] ?? 'No phone';
          _profileImageUrl = userDoc['profileImage'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "asset/image/bg.jpg"), // Change to your image path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              SizedBox(height: 60),

              // App Bar with Profile Title and Logout Button
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
                      icon: Icon(Icons.logout,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          size: 28),
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
                    child: _profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _profileImageUrl!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.red, size: 40),
                          )
                        : Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Name and Email
              Text(
                _name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 50),

              // Profile Options
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
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
                            builder: (context) => UserEditScreen(),
                          ),
                        ).then((_) => _fetchUserData());
                      }),

                      SizedBox(height: 15), // Space between buttons

                      _buildProfileOption(Icons.shopping_bag, "My Orders", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserOrderViewScreen(),
                          ),
                        );
                      }),

                      SizedBox(height: 15), // Space between buttons

                      _buildProfileOption(Icons.lock, "Change Password", () {
                        // Navigate to Change Password
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
