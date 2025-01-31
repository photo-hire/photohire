import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/photographer/photographer_root_screen.dart';
import 'package:photohire/rentalStore/store_root_screen.dart';
import 'package:photohire/user/route_screen.dart';
import 'package:photohire/user/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      // Background gradient
      Image.asset(
        'asset/image/frontscreen.jpg', // Replace with your image path
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login Now',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 24.0.h,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16.0.h),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility // Eye icon for visible password
                        : Icons
                            .visibility_off, // Eye icon with a slash for hidden password
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible =
                          !_isPasswordVisible; // Toggle the visibility state
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24.0.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  isLoading = true;
                  setState(() {});
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text);

                  final userId = userCredential.user?.uid;

                  // Check in Photographer collection
                  final photographerDoc = await FirebaseFirestore.instance
                      .collection('photgrapher')
                      .doc(userId)
                      .get();

                  if (photographerDoc.exists) {
                    // Navigate to PhotographerDetailsScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotographerRootScreen(),
                      ),
                    );
                    return; // Exit after successful navigation
                  }
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();

                  if (userDoc.exists) {
                    // Navigate to UserRegisterScreen (replace with the correct screen for users)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RootScreen(),
                      ),
                    );
                    return; // Exit after successful navigation
                  }

                  final storeDoc = await FirebaseFirestore.instance
                      .collection('rentalStore')
                      .doc(userId)
                      .get();


                  if (storeDoc.exists) {
                    // Navigate to UserRegisterScreen (replace with the correct screen for users)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreRootScreen(),
                      ),
                    );
                    return; // Exit after successful navigation
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User Not found'),
                  ));
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Login Failed: $e'),
                  ));
                } finally {
                  isLoading = false;
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
            ),
            SizedBox(height: 16.0.h),
            Text(
              'Create an Account',
              style: TextStyle(
                  color: Colors.yellow[700],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Choosing()));
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    ]));
  }
}
