import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'cloudinary_helper.dart'; // Import the helper class

class StudioRegistrationScreen extends StatefulWidget {
  @override
  _StudioRegistrationScreenState createState() =>_StudioRegistrationScreenState();
}

class _StudioRegistrationScreenState extends State<StudioRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studioNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _licenseImage;
  File? _logoImage;

  final _picker = ImagePicker();
  final CloudinaryHelper _cloudinaryHelper = CloudinaryHelper(
    uploadUrl: "YOUR_CLOUDINARY_UPLOAD_URL",
    uploadPreset: "YOUR_UPLOAD_PRESET",
  );

  Future<void> _pickImage(bool isLicense) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLicense) {
          _licenseImage = File(pickedFile.path);
        } else {
          _logoImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _licenseImage != null &&
        _logoImage != null) {
      try {
        // Upload images using Cloudinary helper
        final licenseImageUrl = await _cloudinaryHelper.uploadImage(_licenseImage!);
        final logoImageUrl = await _cloudinaryHelper.uploadImage(_logoImage!);

        // Firebase Authentication
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save to Firestore
        final studioData = {
          'studioName': _studioNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
          'studioLicense': licenseImageUrl,
          'studioLogo': logoImageUrl,
        };

        await FirebaseFirestore.instance
            .collection('studios')
            .doc(userCredential.user!.uid)
            .set(studioData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Studio registered successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and upload images')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            "assets/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Text(
                      "Studio Registration",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _studioNameController,
                      hint: "Studio Name",
                      validator: (value) => value!.isEmpty
                          ? "Please enter the studio name"
                          : null,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      hint: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _phoneNumberController,
                      hint: "Phone Number",
                      validator: (value) => value!.isEmpty
                          ? "Please enter your phone number"
                          : null,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      isPassword: true,
                      validator: (value) => value!.length < 6
                          ? "Password must be at least 6 characters"
                          : null,
                    ),
                    

                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      isPassword: true,
                      validator: (value) => value != _passwordController.text
                          ? "Passwords do not match"
                          : null,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage(true),
                          child: Text("Upload License"),
                        ),
                        ElevatedButton(
                          onPressed: () => _pickImage(false),
                          child: Text("Upload Logo"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
