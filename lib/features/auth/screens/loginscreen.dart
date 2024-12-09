import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/features/auth/screens/user_registration_screen.dart';
import 'package:photohire/user/user_home_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "asset/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          // Foreground Elements
          Positioned(
            top: 150.h,
            bottom: 0,
            left: 50.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First Text Field
                Text(
                      "Login Now",
                      style: TextStyle(
                        color: Colors
                            .white, // This color is a fallback and won't affect the gradient
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20,),
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Second Text Field
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Login Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Color(0xffFFDD85), Color(0xffF8B500)],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      fixedSize: Size(175.w, 60.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => UserHomeScreen(),));

                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xff03399E),
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50.h),

                // "Don't have an account?" Text
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 5.h),

                // "Register Now" Button
                TextButton(
                  onPressed: () {
                    print('fff');

                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserRegistrationScreen(),));
                    // Handle Register Now action
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Color(0xffFFDD85), Color(0xffF8B500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                        color: Colors
                            .white, // This color is a fallback and won't affect the gradient
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Positioned Image
               
              ],
            ),
          ),

           Positioned(
             bottom: -50.h,
             left: 0,
             right: 0,
             child: Image.asset(
                    "asset/image/Saly-39.png",
                    height: 300.h,
                    width: 300.w,
                  ),
           ),
        ],
      ),
    );
  }
}
