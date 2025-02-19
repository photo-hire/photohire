import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'asset/image/frontscreen.jpg',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.only(top: 120.h, left: 50.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: GoogleFonts.satisfy(
                    textStyle: TextStyle(
                        fontSize: 46.sp,
                        color: Color(0xFFF8B500),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Welcome to",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 25.sp, color: Colors.white, height: 1),
                  ),
                ),
                Text(
                  "PhotoHire",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 48.sp,
                          height: 1,
                          fontWeight: FontWeight.bold)),
                ),
                Text(
                  "Dive into the world\nof Photography",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w300)),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Image.asset("asset/image/firsticon.png",
                      height: 300.h, width: 300.w),
                ),
                SizedBox(height: 30.h),
                Center(
                  child: SizedBox(
                    width: 250.w,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.sp),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.arrow_right_alt_sharp)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
