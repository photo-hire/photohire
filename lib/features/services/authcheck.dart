import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:photohire/photographer/photographer_root_screen.dart';
import 'package:photohire/rentalStore/rental_store_home_screen.dart';
import 'package:photohire/rentalStore/store_root_screen.dart';
import 'package:photohire/user/route_screen.dart';
import 'package:photohire/user/user_home_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Text('Loading');
          }
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user == null) {
              print('data');
              return const SplashScreen();
            } else {
              return 
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if(userSnapshot.connectionState ==ConnectionState.waiting){
                              return Scaffold(body: Center(child: CircularProgressIndicator(),));
                            }

                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      return RootScreen();
                    } else {
                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('photgrapher')
                              .doc(user.uid)
                              .get(),
                          builder: (context, companySnapshot) {
                            if(companySnapshot.connectionState ==ConnectionState.waiting){
                              return Scaffold(body: Center(child: CircularProgressIndicator(),));
                            }

                            if (companySnapshot.hasData &&
                                companySnapshot.data!.exists) {
                              return PhotographerRootScreen();
                            } else {
                              
                              return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('rentalStore')
                              .doc(user.uid)
                              .get(),
                          builder: (context, companySnapshot) {
                            if(companySnapshot.connectionState ==ConnectionState.waiting){
                              return Scaffold(body: Center(child: CircularProgressIndicator(),));
                            }

                            if (companySnapshot.hasData &&
                                companySnapshot.data!.exists) {
                              return StoreRootScreen();
                            } else {
                              
                              return SplashScreen();
                            }
                          });
                            }
                          });
                    }
                  });
            }
          }
          return  Center(
            child: CircularProgressIndicator(
              color: Colors.blue[900],
            ),
          );
        });
  }
}