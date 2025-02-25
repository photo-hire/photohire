import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/photographer/Location_picker_screen.dart';
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
  TextEditingController descController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool isFreelancer = false;
  bool isProfessional = false;
  String? downloadURL;
  XFile? image;
  File? imageFile;

  double? latitude;
  double? longitude;

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
       await _uploadImage();
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
        setState(() {});
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

  // Fetch current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Location permissions are permanently denied.')),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          _selectedAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location: $e')),
      );
    }
  }

  String? _selectedAddress;

  void _onLocationSelected(double lat, double lng) async {
    setState(() {
      latitude = lat;
      longitude = lng;
    });

    // Convert coordinates to address
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _selectedAddress =
            "${place.street}, ${place.locality}, ${place.country}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Choosing()),
              );
            },
          ),
        ),
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
                        backgroundImage:
                            image == null ? null : FileImage(File(image!.path)),
                        child: image == null
                            ? Center(
                                child: Text(
                                'Company logo here',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.sp),
                              ))
                            : null,
                      )),
                  SizedBox(
                    height: 16.0.h,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                      hintText: 'Company Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                                isFreelancer =
                                    false; // Only one can be selected
                              });
                            },
                            activeColor: Colors.white,
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
                            activeColor: Colors.white,
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
                      hintText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0.h),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      hintText: 'Starting Price',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                  // Button to fetch current location
                  ElevatedButton(
                    onPressed: () {
                      if (latitude != null && longitude != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LocationPickerScreen(
                                  onLocationSelected: _onLocationSelected,
                                  latitude: latitude!,
                                  longitude: longitude!,
                                )));
                      } else {
                        _getCurrentLocation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                    ),
                    child: Text(
                      latitude != null && longitude != null
                          ? 'Select on Map'
                          : 'Get Current Location',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0.h),
                  // Display latitude and longitude
                  if (latitude != null && longitude != null)
                    if (_selectedAddress != null)
                      Text(
                        'Address: $_selectedAddress',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                  SizedBox(height: 16.0.h),
                  TextField(
                    maxLines: 4,
                    controller: descController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                        if (nameController.text.isEmpty) {
                          showError('Name cannot be empty', context);
                          return;
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(emailController.text)) {
                          showError(
                              'Please enter a valid email address', context);
                          return;
                        }

                        if (passwordController.text.length < 6) {
                          showError(
                              'Password must be at least 6 characters long',
                              context);
                          return;
                        }

                        if (!RegExp(r'^\d{10}$')
                            .hasMatch(phoneController.text)) {
                          showError(
                              'Please enter a valid 10-digit phone number',
                              context);
                          return;
                        }

                        if (companyController.text.isEmpty) {
                          showError('Company name cannot be empty', context);
                          return;
                        }

                        if (priceController.text.isEmpty ||
                            double.tryParse(priceController.text) == null) {
                          showError('Please enter a valid price', context);
                          return;
                        }

                        if (descController.text.isEmpty) {
                          showError('Description cannot be empty', context);
                          return;
                        }

                        if(downloadURL == null){
                          showError('Please upload a logo', context);
                          return;
                        }

                        // Proceed with form submission if all validations pass

                        String userType =
                            isProfessional ? 'Professional' : 'Freelancer';

                        isLoading = true;
                        setState(() {});
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                        String uid = FirebaseAuth.instance.currentUser!.uid;

                       

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
                          'latitude': latitude,
                          'longitude': longitude,
                          'Description': descController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registered Successfully')));
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'The email address is already in use by another account.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('An error occurred: ${e.message}')),
                          );
                        }
                      } catch (e) {
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
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
        ]),
      ),
    );
  }
}

void showError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
