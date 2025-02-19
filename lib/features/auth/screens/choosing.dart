import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/admin/adminlogin.dart';
import 'package:photohire/features/auth/screens/rental_store_register_screen.dart';
import 'package:photohire/features/auth/screens/photographerRegister.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:photohire/features/auth/screens/userregisterscree.dart';

class Choosing extends StatefulWidget {
  const Choosing({super.key});

  @override
  State<Choosing> createState() => _ChoosingState();
}

class _ChoosingState extends State<Choosing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image.asset(
            "asset/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          /// Back Button
          Positioned(
            top: 30.h,
            left: 10.w,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          /// Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// User Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(250.w, 60.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserRegisterScreen()),
                  );
                },
                child: Text(
                  "USER",
                  style: TextStyle(
                    color: Color(0xff03399E),
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// Photographer Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    colors: [Color(0xffFFDD85), Color(0xffF8B500)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    fixedSize: Size(250.w, 60.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhotographerRegister()),
                    );
                  },
                  child: Text(
                    "PHOTOGRAPHER",
                    style: TextStyle(
                      color: Color(0xff03399E),
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// Rental Store Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(250.w, 60.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RentalStoreRegisterScreen()),
                  );
                },
                child: Text(
                  "RENTAL STORE",
                  style: TextStyle(
                    color: Color(0xff03399E),
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),

          /// Bottom Image
          Positioned(
            bottom: 0.h,
            left: MediaQuery.of(context).size.width / 2 - 150.w,
            child: Image.asset(
              "asset/image/choose.png",
              height: 300.h,
              width: 300.w,
            ),
          ),
        ],
      ),
    );
  }
}
