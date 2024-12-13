import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
          Image.asset(
            "asset/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 30.h,
            left: 10.w,
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ));
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 200.h),
                child: Text(
                  "I WANT TO",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 30.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(175, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserRegisterScreen()));
                  },
                  child: Text(
                    "HIRE",
                    style: TextStyle(
                        color: Color(0xff03399E),
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 20.h,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    gradient: LinearGradient(
                        colors: [Color(0xffFFDD85), Color(0xffF8B500)])),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        fixedSize: Size(175, 60),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r))),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhotographerRegister()));
                    },
                    child: Text(
                      "BE HIRED",
                      style: TextStyle(
                          color: Color(0xff03399E),
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              SizedBox(
                height: 20.h,
              ),

              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(175, 70),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RentalStoreRegisterScreen()));
                  },
                  child: Text(
                    "RENTAL STORE",
                    style: TextStyle(color: Color(0xff03399E), fontSize: 25.sp,fontWeight: FontWeight.bold),
                  )),
              
              SizedBox(height: 30.h,),


              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(175, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r))),
                  onPressed: () {},
                  child: Text(
                    "Admin",
                    style: TextStyle(
                        color: Color(0xff03399E),
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          Positioned(
              bottom: 0.h,
              left: 50.w,
              child: Image.asset(
                "asset/image/choose.png",
                height: 300.h,
                width: 300.w,
              )),
        ],
      ),
    );
  }
}
