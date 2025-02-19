import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class StoreAddProductScreen extends StatefulWidget {
  const StoreAddProductScreen({super.key});

  @override
  State<StoreAddProductScreen> createState() => _StoreAddProductScreenState();
}

class _StoreAddProductScreenState extends State<StoreAddProductScreen> {
  bool isLoading = false;
  String? downloadURL;
  XFile? image;
  File? imageFile;
  TextEditingController descController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
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
                'Manage Your Products',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('Add a new product'),
                            content: SingleChildScrollView(
                              child: Column(
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
                                        borderRadius:
                                            BorderRadius.circular(10.r),
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
                                        labelText: 'Name',
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
                                          String title =
                                              titleController.text.trim();
                                          String description =
                                              descController.text.trim();
                                          String price =
                                              priceController.text.trim();

                                          // Post details
                                          Map<String, dynamic> productDetails =
                                              {
                                            'name': title,
                                            'description': description,
                                            'price': price,
                                            'image': downloadURL,
                                          };
                                          final productRef = FirebaseFirestore
                                              .instance
                                              .collection('storeProducts')
                                              .doc();
                                          await productRef.set({
                                            'userId': userId,
                                            'productDetails': [productDetails],
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Product added successfully')),
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
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Add a new product',
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
                'Your Products',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('storeProducts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No products found'));
                        }

                        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                            storeProducts = snapshot.data!.docs.where((doc) {
                          return doc.data()['userId'] == userId;
                        }).toList();

                        final List<Map<String, dynamic>> productDetails =
                            storeProducts.expand((doc) {
                          return List<Map<String, dynamic>>.from(
                              doc.data()['productDetails'] ?? []);
                        }).toList();

                        return productDetails.isEmpty
                            ? const Center(
                                child: Text('No products to display'))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Number of columns
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio:
                                        0.75, // Adjust this to fit your design
                                  ),
                                  itemCount: productDetails.length,
                                  itemBuilder: (context, index) {
                                    final product = productDetails[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.r)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.r),
                                                topRight:
                                                    Radius.circular(10.r)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Image.network(
                                                product['image'],
                                                fit: BoxFit.cover,
                                                height: 150.h,
                                                // width: double.infinity,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'],
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '\₹${product['price']}',
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                      }))
            ],
          ),
        ),
      ),
    ));
  }
}
