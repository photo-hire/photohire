import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photohire/admin/admin_home_screen.dart';
import 'package:photohire/admin/studio_management_screen.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        home: AdminHomeScreen(),
      );
    }
  ));
}
