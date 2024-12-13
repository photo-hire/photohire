import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class PhotographerManageProfileScreen extends StatefulWidget {
  const PhotographerManageProfileScreen({super.key});

  @override
  State<PhotographerManageProfileScreen> createState() =>
      _PhotographerManageProfileScreenState();
}

class _PhotographerManageProfileScreenState
    extends State<PhotographerManageProfileScreen> {
  bool isLoading = false;
  String? downloadURL;
  XFile? image;
  File? imageFile;
  TextEditingController descController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.uid;

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
          padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Your Profile',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30.h,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('Add a new post'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await _pickImage();
                                    // Update the state of the dialog to reflect the selected image
                                    setDialogState(() {});
                                  },
                                  child: Container(
                                    height: 190.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                          color: Colors.black,
                                          width: 2.w,
                                          style: BorderStyle.solid),
                                    ),
                                    child: imageFile == null
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
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                ),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                      labelText: 'Title',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r))),
                                ),
                                SizedBox(
                                  height: 16.h,
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
                                  height: 24.h,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      isLoading = true;
                                      setDialogState(() {});
                                      await _uploadImage();
                                      if (downloadURL != null) {
                                       
                                        String title =
                                            titleController.text.trim();
                                        String description =
                                            descController.text.trim();

                                        // Post details
                                        Map<String, dynamic> postDetails = {
                                          'title': title,
                                          'description': description,
                                          'image': downloadURL,
                                        };
                                        final postDocRef = FirebaseFirestore
                                            .instance
                                            .collection('posts')
                                            .doc(userId);
                                        final docSnapshot =
                                            await postDocRef.get();
                                        if (docSnapshot.exists) {
                                          // Update existing post details
                                          await postDocRef.update({
                                            'postDetails':
                                                FieldValue.arrayUnion(
                                                    [postDetails]),
                                          });
                                        } else {
                                          // Create a new document with post details
                                          await postDocRef.set({
                                            'userId': userId,
                                            'postDetails': [postDetails],
                                          });
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Post added successfully')),
                                        );
                                        titleController.clear();
                                        descController.clear();
                                        setState(() {
                                          imageFile = null;
                                          downloadURL = null;
                                        });
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
                                        borderRadius: BorderRadius.circular(10.r),
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
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 60.h,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Add a new post',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.sp),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                'Your Profile',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No posts found'));
          }

          // Extract the postDetails list
          List<Map<String, dynamic>> postDetails = List<Map<String, dynamic>>.from(snapshot.data!['postDetails'] ?? []);

          return postDetails.isEmpty
              ? const Center(child: Text('No posts to display'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75, // Adjust this to fit your design
                    ),
                    itemCount: postDetails.length,
                    itemBuilder: (context, index) {
                      final post = postDetails[index];
                      return ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        post['image'],
                        fit: BoxFit.cover,
                        height: 150.h,
                        width: double.infinity,
                      ),
                    );
                    },
                  ),
                );
        }
                )
              )
            ],
          ),
        ),
      ),
    ));
  }
}
