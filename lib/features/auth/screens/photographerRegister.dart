import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/photographer/explore_screen.dart';
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
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool isFreelancer = false;
  bool isProfessional = false;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Register Now',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 24.0,
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(
                height: 16.0,
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
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
                      const Text("Professional",style: TextStyle(
                        color: Colors.white
                      ),),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isFreelancer,
                        onChanged: (value) {
                          setState(() {
                            isFreelancer = value!;
                            isProfessional = false; // Only one can be selected
                          });
                        },
                        activeColor: Colors.white, // Fill color
                        checkColor: Colors.blue[900],
                      ),
                      const Text("Freelancer",style: TextStyle(
                        color: Colors.white
                      ),),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16.4,
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  try {
                    String userType = isProfessional ? 'Professional' : 'Freelancer';

                    isLoading = true;
                    setState(() {});
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
                      'role':userType
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registered Successffully')));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>PhotographerRootScreen()));
                  } catch (e) {
                    print(e);
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
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Already have an account',
                style: TextStyle(
                    color: Colors.yellow[700],
                    fontSize: 18,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ),
      ])),
    );
  }
}
