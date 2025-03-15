import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photohire/user/photographer_details_screen.dart';
import 'package:photohire/user/user_google_map_explore_screen.dart';
import 'package:photohire/user/user_profile_screen.dart';

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
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    getData();
    _getCurrentLocation();
    _fetchUserProfileImage();
  }

  // Fetch User Profile Image from Firestore
  Future<void> _fetchUserProfileImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          profileImageUrl = userDoc.data()!['profileImage'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
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
        if (mounted) {
          setState(() {
            _currentLocation = "${place.locality}, ${place.administrativeArea}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = "Failed to fetch location.";
        });
      }
    }
  }

  Future<void> getData() async {
    try {
      setState(() => isLoading = true);

      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('photographer').get();

      studioData = snapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .map((doc) => {'data': doc.data(), 'id': doc.id})
          .toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
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
                            _currentLocation,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : AssetImage("asset/image/avatar.png")
                                  as ImageProvider,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.sp),
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
                            latlnglist: [],
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
                          horizontal: 15, vertical: 15),
                      child: Icon(Icons.map),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : studioData.isNotEmpty
                    ? Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                              child: Card(child: Text(photographer['company'])),
                            );
                          },
                        ),
                      )
                    : Center(child: Text('No data available'))
          ],
        ),
      ),
    );
  }
}
