import 'package:flutter/material.dart';

class PhotoggrapherProfileScreen extends StatefulWidget {
  const PhotoggrapherProfileScreen({super.key});

  @override
  State<PhotoggrapherProfileScreen> createState() => _PhotoggrapherProfileScreenState();
}

class _PhotoggrapherProfileScreenState extends State<PhotoggrapherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient:  LinearGradient(
            transform: GradientRotation(11),
            
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white,      // White (Bottom)
            ],
          ),
      
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 50, 15,0),
          child: Column(
            children: [
              
              Row(
                children: [
                  Icon(Icons.settings_outlined,),
                  SizedBox(width: 10,),
                  Text('Settings',style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                    ),),
                ],
              ),
                SizedBox(height: 30,),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.edit_square,color: Colors.grey,),
                      SizedBox(width: 10,),
                      Text('Edit Your Profile',style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.phone,color: Colors.grey,),
                      SizedBox(width: 10,),
                      Text('Change Mobile Number',style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.logout,color: Colors.grey,),
                      SizedBox(width: 10,),
                      Text('Logout',style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15
                      ),)
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      
                      Positioned(
                        left: 30,
                        bottom: 10,
                        child: Image.asset('asset/image/Saly-2.png'))
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    ));
  }
}