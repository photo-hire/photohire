import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohire/features/auth/screens/choosing.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/user/route_screen.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Pick Image Function
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload Image to Firebase Storage and return URL
  Future<String?> _uploadImage(File image, String userId) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Validate Phone Number
  bool _isValidPhoneNumber(String number) {
    return RegExp(r'^\d{10}$').hasMatch(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/image/frontscreen.jpg',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
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
                SizedBox(height: 24.0.h),

                // Profile Picture Upload (Mandatory)
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 30, color: Colors.red),
                              Text(
                                'Upload\nPhoto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.red),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 16.h),

                // Text Fields
                _buildTextField(nameController, 'Name'),
                _buildTextField(phoneController, 'Phone Number', isPhone: true),
                _buildTextField(emailController, 'Email'),
                _buildPasswordField(),

                SizedBox(height: 24.0.h),

                // Register Button
                ElevatedButton(
                  onPressed: () async {
                    if (_image == null) {
                      _showSnackBar(
                          'Please upload a profile picture', Colors.red);
                      return;
                    }
                    if (!_isValidPhoneNumber(phoneController.text)) {
                      _showSnackBar(
                          'Phone number must be exactly 10 digits', Colors.red);
                      return;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(emailController.text)) {
                      _showSnackBar('Please enter a valid email', Colors.red);
                      return;
                    }
                    if (passwordController.text.length < 6) {
                      _showSnackBar(
                          'Password must be at least 6 characters', Colors.red);
                      return;
                    }

                    try {
                      isLoading = true;
                      setState(() {});

                      // Create user
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      String uid = userCredential.user!.uid;

                      // Upload Profile Image (Mandatory)
                      String imageUrl = await _uploadImage(_image!, uid) ?? '';

                      // Save user details in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                        'profileImage': imageUrl,
                      });

                      _showSnackBar(
                          'User Registered Successfully', Colors.green);

                      // Navigate to Home Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RootScreen()),
                      );
                    } catch (e) {
                      _showSnackBar('Error: ${e.toString()}', Colors.red);
                    } finally {
                      isLoading = false;
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                ),
                SizedBox(height: 16.0.h),

                Text(
                  'Already have an account?',
                  style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Snackbar Function
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.r)),
        ),
      ),
    );
  }

  // Password TextField with Visibility Toggle
  Widget _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.r)),
          suffixIcon: IconButton(
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),
      ),
    );
  }
}
