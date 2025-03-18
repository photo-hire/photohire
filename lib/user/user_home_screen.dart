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
  List<Map<String, dynamic>> filteredData = [];
  String searchQuery = "";
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
          await FirebaseFirestore.instance.collection('photgrapher').get();

      studioData = await Future.wait(snapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .map((doc) async {
        Map<String, dynamic> data = doc.data();
        String photographerId = doc.id;

        // Fetch reviews count
        QuerySnapshot<Map<String, dynamic>> reviewsSnapshot =
            await FirebaseFirestore.instance
                .collection('reviews')
                .where('photographerId', isEqualTo: photographerId)
                .get();
        int reviewsCount = reviewsSnapshot.size;

        // Fetch starting price
        data['startingPrice'] = data['startingPrice']?.toString() ?? "N/A";
        data['reviewsCount'] = reviewsCount;
        return {'data': data, 'id': photographerId};
      }).toList());

      filteredData = List.from(studioData);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterSearchResults(String query) {
    setState(() {
      searchQuery = query;
      filteredData = studioData.where((studio) {
        final studioName = studio['data']['company'].toLowerCase();
        return studioName.contains(query.toLowerCase());
      }).toList();
    });
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
                      Text(_currentLocation,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen())),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _filterSearchResults,
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
                  Container(
                    height: 50.h, // Same height as the search bar
                    width: 50.h, // Keep it square for a clean look
                    decoration: BoxDecoration(
                      color: Colors.green, // Green background
                      borderRadius:
                          BorderRadius.circular(10.r), // Same as search box
                    ),
                    child: IconButton(
                      icon: Icon(Icons.explore_rounded,
                          color: Colors.white, size: 26.sp),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserGoogleMapScreen(
                                latlnglist: [],
                                latlong: LatLng(lat, lng),
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredData.isNotEmpty
                    ? Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(10.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two cards per row
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 0.9, // Slightly taller
                          ),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final photographer = filteredData[index]['data'];
                            final photographerId = filteredData[index]['id'];

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PhotographerDetailsScreen(
                                    studioDetails: photographer,
                                    pid: photographerId,
                                  ),
                                ),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.r), // Rounded corners
                                ),
                                elevation: 4, // Soft shadow effect
                                child: Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Align text left
                                    children: [
                                      // Logo Container (Larger & Rounded)
                                      Container(
                                        width: double.infinity,
                                        height: 100.h, // Increased image size
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                              12.r), // Rounded corners
                                        ),
                                        child: photographer['companyLogo'] !=
                                                    null &&
                                                photographer['companyLogo']
                                                    .isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                child: Image.network(
                                                  photographer['companyLogo'],
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  "LOGO HERE",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Studio Name (Aligned Left)
                                      Text(
                                        photographer['company'] ??
                                            "Unknown Studio",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 4.h),

                                      // Price & Rating (Well-Aligned)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\₹${photographer['startingPrice']}",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          // Row(
                                          //   children: [
                                          //     Icon(Icons.star,
                                          //         color: Colors.amber,
                                          //         size: 16.sp),
                                          //     SizedBox(width: 2.w),
                                          //     Text(
                                          //       photographer['rating']
                                          //               ?.toStringAsFixed(1) ??
                                          //           "N/A",
                                          //       style: TextStyle(
                                          //         fontSize: 13.sp,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(child: Text('No results found')),
          ],
        ),
      ),
    );
  }
}
