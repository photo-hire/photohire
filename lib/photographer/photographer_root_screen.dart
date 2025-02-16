import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photohire/photographer/explore_screen.dart';
import 'package:photohire/photographer/photographer_chat_screen.dart';
import 'package:photohire/photographer/photographer_services_screen.dart';
import 'package:photohire/photographer/photographer_manage_profile_screen.dart';
import 'package:photohire/photographer/photographer_profile_screen.dart';

class PhotographerRootScreen extends StatefulWidget {
      int? index;

  PhotographerRootScreen({super.key,this.index = 0});

  @override
  State<PhotographerRootScreen> createState() => _PhotographerRootScreenState();
}

class _PhotographerRootScreenState extends State<PhotographerRootScreen> {

  int selectedIndex = 0;

  List<Widget> pages =[
    ExploreScreen(),
    PhotographerManageProfileScreen(),
   StudioUserListScreen(studioId: FirebaseAuth.instance.currentUser!.uid,),
    PhotoggrapherProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10)
        ),
        child: BottomNavigationBar(
          
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outlined),label: "idea",),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),label: "add",),
            BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'service'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined),label: "profile",),
          ] ,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          selectedIconTheme: IconThemeData(
            size: 40
          ),
          unselectedItemColor:Colors.white,
          backgroundColor: Colors.blue[900],
          currentIndex: selectedIndex,
          ),
      ),
        body: pages[selectedIndex],
    );
  }
}