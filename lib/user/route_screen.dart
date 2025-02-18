import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_booking_list_screen.dart';
import 'package:photohire/user/user_chat_list_screen.dart';
import 'package:photohire/user/user_home_screen.dart';
import 'package:photohire/user/user_profile_screen.dart';
import 'package:photohire/user/user_rent_product_booking_screen.dart';
import 'package:photohire/user/user_rentel_store_product_list.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    UserHomeScreen(),
    UserBookingListScreen(),
    RentalStoreScreen(), // Add the Rental Store screen
    RentelProductBookingListScreen(),
    UserChatListScreen(userId: FirebaseAuth.instance.currentUser!.uid),
    UserProfileScreen(),
  ];
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Ensure all items are visible
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store), // Icon for the Rental Store screen
              label: 'Rental Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined), // Icon for the Rental Store screen
              label: 'Rental bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat), // Icon for the Rental Store screen
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_isDialogShowing) {
      return true; // Allow the dialog to close
    }

    // Show confirmation dialog
    _isDialogShowing = true;
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Do not exit
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Exit the app
            },
            child: Text('OK'),
          ),
        ],
      ),
    );

    _isDialogShowing = false;
    return exit ?? false; // Return false if the dialog is dismissed
  }
}