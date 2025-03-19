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
    apiKey: '142832579599847',
    apiSecret: '2_MaDsMn0MLW5jqxKvxep_tvVJk',
    cloudName: 'dm3mcgkch',
  );

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
    setState(() => imageFile = image != null ? File(image!.path) : null);
  }

  Future<void> _uploadImage() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No image selected')));
      return;
    }

    final response = await cloudinary.upload(
      file: imageFile!.path,
      fileBytes: imageFile!.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      downloadURL = response.secureUrl;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload image')));
    }
  }

  void _confirmDelete(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post?'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(userId)
                  .update({
                'postDetails': FieldValue.arrayRemove([post])
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Your Profile',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('Add a New Post'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await _pickImage();
                                    setDialogState(() {});
                                  },
                                  child: Container(
                                    height: 160.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: imageFile == null
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_upload,
                                                  size: 40, color: Colors.blue),
                                              SizedBox(height: 10.h),
                                              Text('Tap to upload image',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.black54)),
                                            ],
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
                                SizedBox(height: 16.h),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Title',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                TextField(
                                  controller: descController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      isLoading = true;
                                      setDialogState(() {});
                                      await _uploadImage();

                                      if (downloadURL != null) {
                                        Map<String, dynamic> postDetails = {
                                          'title': titleController.text.trim(),
                                          'description':
                                              descController.text.trim(),
                                          'image': downloadURL,
                                        };

                                        final postDocRef = FirebaseFirestore
                                            .instance
                                            .collection('posts')
                                            .doc(userId);
                                        final docSnapshot =
                                            await postDocRef.get();

                                        if (docSnapshot.exists) {
                                          await postDocRef.update({
                                            'postDetails':
                                                FieldValue.arrayUnion(
                                                    [postDetails]),
                                          });
                                        } else {
                                          await postDocRef.set({
                                            'userId': userId,
                                            'postDetails': [postDetails],
                                          });
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Post added successfully')));
                                        titleController.clear();
                                        descController.clear();
                                        setState(() {
                                          imageFile = null;
                                          downloadURL = null;
                                        });
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString())));
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
                                      color: Colors.blue[900],
                                    ),
                                    child: Center(
                                      child: isLoading
                                          ? CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text('Submit',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      'Add a New Post',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Your Posts',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('No posts found'));
                    }

                    List<Map<String, dynamic>> postDetails =
                        List<Map<String, dynamic>>.from(
                            snapshot.data!['postDetails'] ?? []);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: postDetails.length,
                      itemBuilder: (context, index) {
                        final post = postDetails[index];
                        return GestureDetector(
                          onLongPress: () => _confirmDelete(post),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child:
                                Image.network(post['image'], fit: BoxFit.cover),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
