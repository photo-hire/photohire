import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditPhotographerProfileScreen extends StatefulWidget {
  @override
  _EditPhotographerProfileScreenState createState() =>
      _EditPhotographerProfileScreenState();
}

class _EditPhotographerProfileScreenState
    extends State<EditPhotographerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startingPriceController;

  String? _companyLogo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotographerData();
  }

  Future<void> _fetchPhotographerData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot photographerSnapshot = await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(uid)
          .get();

      if (photographerSnapshot.exists) {
        Map<String, dynamic> data =
            photographerSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _nameController = TextEditingController(text: data['name']);
          _companyController = TextEditingController(text: data['company']);
          _emailController = TextEditingController(text: data['email']);
          _phoneController = TextEditingController(text: data['phone']);
          _roleController = TextEditingController(text: data['role']);
          _descriptionController =
              TextEditingController(text: data['description']);
          _startingPriceController =
              TextEditingController(text: data['startingPrice'].toString());
          _companyLogo = data['companyLogo'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String uid = _auth.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(uid)
          .update({
        'name': _nameController.text.trim(),
        'company': _companyController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _roleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startingPrice':
            double.tryParse(_startingPriceController.text.trim()) ?? 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to the previous screen after a short delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image Preview
                    if (_companyLogo != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_companyLogo!),
                      ),
                    SizedBox(height: 20),

                    _buildTextField(_nameController, "Name", Icons.person),
                    _buildTextField(
                        _companyController, "Company", Icons.business),
                    _buildTextField(_emailController, "Email", Icons.email,
                        isEmail: true),
                    _buildTextField(_phoneController, "Phone", Icons.phone,
                        isNumber: true),
                    _buildTextField(_roleController, "Role", Icons.work),
                    _buildTextField(
                        _descriptionController, "Description", Icons.info),
                    _buildTextField(_startingPriceController, "Starting Price",
                        Icons.currency_rupee,
                        isNumber: true),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isEmail = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
