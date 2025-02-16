import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohire/admin/admin_home_screen.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:photohire/photographer/photographer_orders_screen.dart';
import 'package:photohire/photographer/photographers_bookings_list_screen.dart';

class PhotoggrapherProfileScreen extends StatefulWidget {
  const PhotoggrapherProfileScreen({super.key});

  @override
  State<PhotoggrapherProfileScreen> createState() =>
      _PhotoggrapherProfileScreenState();
}

class _PhotoggrapherProfileScreenState
    extends State<PhotoggrapherProfileScreen> {
  bool isLoading = false;
  String? downloadURL;
  XFile? image;
  File? imageFile;
  TextEditingController emailController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: '142832579599847', // Replace with your API key
    apiSecret: '2_MaDsMn0MLW5jqxKvxep_tvVJk', // Replace with your API secret
    cloudName: 'dm3mcgkch', // Replace with your Cloudinary cloud name
  );

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('photgrapher').doc(userId);
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists) {
        var userData = docSnapshot.data();
        emailController.text = userData?['email'] ?? '';
        address1Controller.text = userData?['addressLine1'] ?? '';
        address2Controller.text = userData?['addressLine2'] ?? '';
        descController.text = userData?['Description'] ?? '';
        roleController.text = userData?['role'] ?? '';
        priceController.text = userData?['startingPrice'] ?? '';
        downloadURL = userData?['companyLogo'];
        phoneController.text = userData?['phone'] ?? '';
        setState(() {});
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(11),
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white, // White (Bottom)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 30.sp,
              ),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('Edit your profile'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(children: [
                                    Container(
                                      height: 190.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 2.w,
                                            style: BorderStyle.solid),
                                      ),
                                      child: downloadURL == null
                                          ? imageFile == null
                                              ? Center(
                                                  child: Text(
                                                    'Upload Image',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8.r),
                                                  child: Image.file(
                                                    imageFile!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: Image.network(
                                                downloadURL!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _pickImage();
                                            // Update the state of the dialog to reflect the selected image
                                            setDialogState(() {});
                                          },
                                          child: Container(
                                            width: 50.w,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                                color: Colors.blue[900],
                                                borderRadius:
                                                    BorderRadius.circular(10.r)),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ))
                                  ]),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  TextField(
                                    controller: address1Controller,
                                    decoration: InputDecoration(
                                        labelText: 'Address Line1',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  TextField(
                                    controller: address2Controller,
                                    decoration: InputDecoration(
                                        labelText: 'Address Line 2',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  TextField(
                                    controller: descController,
                                    decoration: InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  TextField(
                                    controller: roleController,
                                    decoration: InputDecoration(
                                        labelText: 'Role',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  TextField(
                                    controller: priceController,
                                    decoration: InputDecoration(
                                        labelText: 'Price',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r))),
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        isLoading = true;
                                        setDialogState(() {});
                                        await _uploadImage();
                                        if (downloadURL != null) {
                                          String email =
                                              emailController.text.trim();
                                          String description =
                                              descController.text.trim();
                                          String price =
                                              priceController.text.trim();
                                          String address1 =
                                              address1Controller.text.trim();
                                          String address2 =
                                              address2Controller.text.trim();
                                          String role =
                                              roleController.text.trim();

                                          Map<String, dynamic> editedData = {
                                            'email': email,
                                            'Description': description,
                                            'startingPrice': price,
                                            'companyLogo': downloadURL,
                                            'addressLine1': address1,
                                            'addressLine2': address2,
                                            'role': role,
                                          };

                                          final userDocRef = FirebaseFirestore
                                              .instance
                                              .collection('photgrapher')
                                              .doc(userId);

                                          final docSnapshot =
                                              await userDocRef.get();
                                          if (docSnapshot.exists) {
                                            // Update existing document
                                            await userDocRef.update(editedData);
                                          } else {
                                            // Create a new document if it doesn't exist
                                            await userDocRef.set(editedData);
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'edited successfully')),
                                          );

                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        print(e);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      } finally {
                                        isLoading = false;
                                        setDialogState(() {});
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: Colors.blue[900]),
                                      child: Center(
                                        child: isLoading
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_square,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'Edit Your Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                          builder: (context, setDialogState) {
                        return AlertDialog(
                          title: Text('Edit your phone number'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r))),
                              ),
                              SizedBox(
                                height: 24.sp,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    isLoading = true;
                                    setDialogState(() {});

                                    await FirebaseFirestore.instance
                                        .collection('photgrapher')
                                        .doc(userId)
                                        .update(
                                            {'phone': phoneController.text});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Mobile number edited successfully')),
                                    );

                                    Navigator.pop(context);
                                  } catch (e) {
                                    print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    isLoading = false;
                                    setDialogState(() {});
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Colors.blue[900]),
                                  child: Center(
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'Submit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'Change Mobile Number',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PhotographerOrdersScreen()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'My Orders',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PhotographerBookingsListScreen()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'My Bookings',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp),
                    )
                  ],
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                        left: 30,
                        bottom: -50,
                        child: Image.asset('asset/image/Saly-2.png'))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
