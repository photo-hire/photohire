import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photohire/photographer/Rentalstoreview.dart';
import 'package:photohire/photographer/photographer_chatList_screen.dart';
import 'package:photohire/photographer/photographer_manage_profile_screen.dart';
import 'package:photohire/photographer/photographersview.dart';

class PhotographerRootScreen extends StatefulWidget {
  int? index;

  PhotographerRootScreen({super.key, this.index = 0});

  @override
  State<PhotographerRootScreen> createState() => _PhotographerRootScreenState();
}

class _PhotographerRootScreenState extends State<PhotographerRootScreen> {
  int selectedIndex = 0;

  List<Widget> pages = [
    PhotographerScreen(), // Photographer Idea Page
    ExploreScreen(), // Explore Page
    PhotographerManageProfileScreen(),
    StudioChatListScreen(
      studioId: FirebaseAuth.instance.currentUser!.uid,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('OK'),
          ),
        ],
      ),
    );
    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blueAccent, // Highlight selected item
          unselectedItemColor: Colors.grey, // Unselected items are grey
          showSelectedLabels: false, // No labels displayed
          showUnselectedLabels: false, // No labels displayed
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outlined, size: 30),
              label: '', // Empty label for minimalism
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined, size: 30),
              label: '', // Empty label for minimalism
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_sharp, size: 30),
              label: '', // Empty label for minimalism
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 30),
              label: '', // Empty label for minimalism
            ),
          ],
        ),
      ),
    );
  }
}
