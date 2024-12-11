import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:photohire/features/auth/screens/splashcreen.dart';
import 'package:photohire/rentalStore/google_map_screen.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  double? latitude;
  double? longitude;

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      Location location = Location();

      // Check if location services are enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // Check if location permissions are granted
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Fetch the current location
      LocationData currentLocation = await location.getLocation();
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
        _latitudeController.text = latitude?.toStringAsFixed(6) ?? '';
        _longitudeController.text = longitude?.toStringAsFixed(6) ?? '';
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location: $e')),
      );
    }
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    try {
      final storeDocRef =
          FirebaseFirestore.instance.collection('rentalStore').doc(userId);
      final docSnapshot = await storeDocRef.get();
      if (docSnapshot.exists) {
        var storeData = docSnapshot.data();
        emailController.text = storeData?['email'] ?? '';
        descController.text = storeData?['description'] ?? '';
        phoneController.text = storeData?['phone'] ?? '';
        _latitudeController.text = storeData?['latitude']??'';
        _longitudeController.text = storeData?['longitude']??'';

        setState(() {});
      }
    } catch (e) {
      print("Error fetching store data: $e");
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
                    width: 10,
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
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
                                  TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
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
                                                BorderRadius.circular(10))),
                                  ),
                                  SizedBox(height: 16,),
                                  TextField(
              controller: _latitudeController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                suffixIcon: IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: _getCurrentLocation,
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            // Longitude TextField
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                suffixIcon: IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: _getCurrentLocation,
                ),
              ),
              readOnly: true,
            ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        isLoading = true;
                                        setDialogState(() {});

                                        String email =
                                            emailController.text.trim();
                                        String description =
                                            descController.text.trim();

                                        Map<String, dynamic> editedData = {
                                          'email': email,
                                          'description': description,
                                          'latitude':latitude,
                                          'longitude':longitude
                                        };

                                        final storeDocRef = FirebaseFirestore
                                            .instance
                                            .collection('rentalStore')
                                            .doc(userId);

                                        final docSnapshot =
                                            await storeDocRef.get();
                                        if (docSnapshot.exists) {
                                          // Update existing document
                                          await storeDocRef.update(editedData);
                                        } else {
                                          // Create a new document if it doesn't exist
                                          await storeDocRef.set(editedData);
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('edited successfully')),
                                        );

                                        Navigator.pop(context);
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
                                              BorderRadius.circular(10),
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
                      width: 10,
                    ),
                    Text(
                      'Edit Your Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
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
                                            BorderRadius.circular(10))),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    isLoading = true;
                                    setDialogState(() {});

                                    await FirebaseFirestore.instance
                                        .collection('rentalStore')
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
                                      borderRadius: BorderRadius.circular(10),
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
                      width: 10,
                    ),
                    Text(
                      'Change Mobile Number',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SplashScreen()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                        left: 30,
                        bottom: 10,
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
