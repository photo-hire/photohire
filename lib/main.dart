import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(ScreenUtilInit(
    designSize: Size(393, 784),
      minTextAdapt: true,
      splitScreenMode: true,
    builder: (context,child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: Choosing(),
      );
    }
  ));
}
