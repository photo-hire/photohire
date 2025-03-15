import 'package:flutter/material.dart';
import 'package:photohire/user/user_rent_product_booking_screen.dart';
import 'user_booking_list_screen.dart'; // Import the photographer bookings screen
// import 'rental_product_booking_list_screen.dart'; // Import the rental store bookings screen

class UserOrderViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                SizedBox(height: 10),

                // Title
                Text(
                  "My Orders",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 30),

                // Photographer Orders Button
                _buildOrderCard(
                  context,
                  title: "Photographers",
                  imagePath: "asset/image/photographer.png",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserBookingListScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),

                // Rental Store Orders Button
                _buildOrderCard(
                  context,
                  title: "Rental Store",
                  imagePath: "asset/image/camera.png",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RentelProductBookingListScreen(),
                      ),
                    );
                  },
                ),

                Spacer(),

                // Bottom Illustration
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "asset/image/checklist.png", // Ensure this file exists
                    width: 180,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context,
      {required String title,
      required String imagePath,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Image
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(imagePath),
            ),

            // Title
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Forward Arrow
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
