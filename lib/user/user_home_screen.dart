import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/admin/admin_home_screen.dart';
import 'package:photohire/user/photographer_details_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> studioData = [];
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      isLoading = true;
      setState(() {});

      // Fetch the documents in the 'photographer' collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('photgrapher').get();

      // Extract data from each document and return as a list of maps
      studioData = snapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .map((doc) => {'data':doc.data(), 'id': doc.id})
          .toList();
      isLoading = false;
      setState(() {});
      return studioData;
    } catch (e) {
      isLoading = false;
      setState(() {});
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
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
                              "Kozhikode, Kerala",
                              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: CircleAvatar(
                        backgroundImage: AssetImage(
                            "asset/image/image1.jpg"), // Replace with your profile image asset
                        radius: 20.r,
                      ),
                      onSelected: (value) {
                        if (value == 'Sign out') {
                          FirebaseAuth.instance.signOut();
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
                    // Search Bar
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
                    // Toggle Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: const Text(
                        "LIST",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
          
              // Grid View of Items
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : studioData.length > 0
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
                            itemCount:
                                studioData.length, // The filtered data count
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
                                                pid:studioData[index]['id'],
                                              )));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Logo Section
                                      Container(
                                        height: 100.h,
                                        width: double.infinity,
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Center(
                                            child: photographer['companyLogo'] ==
                                                    null
                                                ? Text(
                                                    "LOGO HERE",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  )
                                                : Image.network(
                                                    photographer['companyLogo'],
                                                    fit: BoxFit.fill,
                                                  )),
                                      ),
          
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title and Description
                                            Row(
                                              children: [
                                                Text(
                                                  photographer['company'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  "4.5",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 16),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Text(
                                              "${photographer['role']} Photographers",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(height: 5.h),
          
                                            // Price
                                            Text(
                                              '\$ ${photographer['startingPrice']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text('No data available'),
                        )
            ],
          ),
        ),
        backgroundColor: Colors.purple[50], // Matches the gradient in the image.
      ),
    );
  }
}
