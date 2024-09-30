import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';

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
              Text(
                "I am",
                style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 32)),
              )
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
