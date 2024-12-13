import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/photographer/photographer_root_screen.dart';

class PhotographerRegister extends StatefulWidget {
  const PhotographerRegister({super.key});

  @override
  State<PhotographerRegister> createState() => _PhotographerRegisterState();
}

class _PhotographerRegisterState extends State<PhotographerRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool isFreelancer = false;
  bool isProfessional = false;
  String? downloadURL;
  XFile? image;
  File? imageFile;

   final cloudinary = Cloudinary.signedConfig(
    apiKey: '142832579599847', // Replace with your API key
    apiSecret: '2_MaDsMn0MLW5jqxKvxep_tvVJk', // Replace with your API secret
    cloudName: 'dm3mcgkch', // Replace with your Cloudinary cloud name
  );

  Future<void> _pickImage() async {
   
      // Pick an image from the gallery
      final ImagePicker picker = ImagePicker();
      image = await picker.pickImage(source: ImageSource.gallery);
      setState(() {});

      if (image != null) {
        // Get the image file
        imageFile = File(image!.path);
        setState(() {});
      }
   
  }

  Future<void> _uploadImage() async {
    if (imageFile != null) {
      final response = await cloudinary.upload(
        file: imageFile!.path,
        fileBytes: imageFile!.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
      );

      if (response.isSuccessful) {
        downloadURL = response.secureUrl;
        setState(() {
          
        });
        print('Upload Successful. URL: ${response.secureUrl}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        print('Upload Failed: ${response.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(fit: StackFit.expand, children: [
        // Background gradient
        Image.asset(
          'asset/image/frontscreen.jpg', // Replace with your image path
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),

        Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Register Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 24.0.h,
                ),
                GestureDetector(
                    onTap: () async {
                      _pickImage();
                    },
                    child: CircleAvatar(
                      radius: 60.r,
                      backgroundColor: Colors.white,

                      backgroundImage: image == null
                          ? null
                          : FileImage(File(image!
                              .path)), // Use FileImage to display the image
                      child: image == null
                          ? Center(
                              child: Text(
                              'Company logo here',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13.sp),
                            ))
                          : null, // Display text only when no image is present
                    )),
                SizedBox(
                  height: 16.0.h,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                SizedBox(
                  height: 16.0.h,
                ),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
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
                // Checkboxes for Professional and Freelancer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isProfessional,
                          onChanged: (value) {
                            setState(() {
                              isProfessional = value!;
                              isFreelancer = false; // Only one can be selected
                            });
                          },
                          activeColor: Colors.white, // Fill color
                          checkColor: Colors.blue[900],
                        ),
                        const Text(
                          "Professional",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isFreelancer,
                          onChanged: (value) {
                            setState(() {
                              isFreelancer = value!;
                              isProfessional =
                                  false; // Only one can be selected
                            });
                          },
                          activeColor: Colors.white, // Fill color
                          checkColor: Colors.blue[900],
                        ),
                        const Text(
                          "Freelancer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.4.h,
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
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
                SizedBox(height: 16.0.h),

                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Starting Price',
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
                  controller: address1Controller,
                  decoration: InputDecoration(
                    labelText: 'Address Line 1',
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
                  controller: address2Controller,
                  decoration: InputDecoration(
                    labelText: 'Address Line 2',
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
                  maxLines: 4,
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
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
                SizedBox(height: 24.0.h),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String userType =
                          isProfessional ? 'Professional' : 'Freelancer';

                      isLoading = true;
                      setState(() {});
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                      String uid = FirebaseAuth.instance.currentUser!.uid;

                      await _uploadImage();

                      await FirebaseFirestore.instance
                          .collection('photgrapher')
                          .doc(uid)
                          .set({
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                        'company': companyController.text,
                        'role': userType,
                        'companyLogo': downloadURL,
                        'startingPrice': priceController.text,
                        'isApproved': false,
                        'addressLine1': address1Controller.text,
                        'addressLine2': address2Controller.text,
                        'Description': descController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registered Successffully')));
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhotographerRootScreen()));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'email-already-in-use') {
                        // Display a user-friendly message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'The email address is already in use by another account.')),
                        );
                      } else {
                        // Handle other Firebase exceptions
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('An error occurred: ${e.message}')),
                        );
                      }
                    } catch (e) {
                      // Handle general exception
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('An unexpected error occurred.')),
                      );
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                ),
                SizedBox(height: 16.0.h),
                Text(
                  'Already have an account',
                  style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ),
      ])),
    );
  }
}
