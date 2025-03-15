import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photohire/features/auth/screens/loginscreen.dart';
import 'package:photohire/user/photographer_details_screen.dart';
import 'package:photohire/user/user_google_map_explore_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> studioData = [];
  String _currentLocation = "Fetching location...";
  double lat = 0.0;
  double lng = 0.0;
  List<LatLng> latLngList = [];

  @override
  void initState() {
    super.initState();
    getData();
    _getCurrentLocation();
  }

  // Fetch current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      lat = position.latitude;
      lng = position.longitude;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentLocation = "${place.locality}, ${place.administrativeArea}";
        });
      } else {
        setState(() {
          _currentLocation = "Location not found.";
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Failed to fetch location.";
      });
    }
  }

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('photgrapher').get();

      studioData = snapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .map((doc) => {'data': doc.data(), 'id': doc.id})
          .toList();

      for (var studio in studioData) {
        var data = studio['data'];
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          double lat = (data['latitude'] as num).toDouble();
          double lng = (data['longitude'] as num).toDouble();
          latLngList.add(LatLng(lat, lng));
        }
      }

      setState(() {
        isLoading = false;
      });

      return studioData;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to fetch data');
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
                Color.fromARGB(255, 200, 148, 249),
                Color.fromARGB(255, 162, 213, 255),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Top Section: Location and Profile Icon
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.purple),
                        SizedBox(width: 5.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Home",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            Text(
                              _currentLocation,
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: CircleAvatar(
                        backgroundImage: AssetImage("asset/image/image1.jpg"),
                        radius: 20.r,
                      ),
                      onSelected: (value) async {
                        if (value == 'Sign out') {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'Sign out',
                          child: Text('Sign out'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.sp),

              // Search Bar and Toggle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserGoogleMapScreen(
                              latlnglist: latLngList,
                              latlong: LatLng(lat, lng),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Icon(Icons.map),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Grid View of Items
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : studioData.isNotEmpty
                      ? Expanded(
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: studioData.length,
                            itemBuilder: (context, index) {
                              final photographer = studioData[index]['data'];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PhotographerDetailsScreen(
                                        studioDetails: photographer,
                                        pid: studioData[index]['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Text(photographer['company']),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(child: Text('No data available'))
            ],
          ),
        ),
      ),
    );
  }
}
