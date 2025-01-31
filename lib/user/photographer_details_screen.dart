import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photohire/user/booking_photographers_screen.dart';
import 'package:photohire/user/portfolio_screen.dart';
import 'package:photohire/user/user_chat_screen.dart';

class PhotographerDetailsScreen extends StatefulWidget {
  Map<String, dynamic> studioDetails;
  String? pid;

  PhotographerDetailsScreen(
      {super.key, required this.studioDetails, required this.pid});

  @override
  State<PhotographerDetailsScreen> createState() =>
      _PhotographerDetailsScreenState();
}

class _PhotographerDetailsScreenState extends State<PhotographerDetailsScreen> {
  List<String> images = []; // List to hold image URLs
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchPostDetails(); // Fetch the post details when the screen is initialized
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fetch post details from Firestore
  Future<void> _fetchPostDetails() async {
    try {
      // Assuming the Firestore collection name is 'postDetails'
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: widget.pid) // Filter by userId
          .get()
          .then((querySnapshot) {
        List<String> fetchedImages = [];
        querySnapshot.docs.first['postDetails'].forEach((doc) {
          // Get image URL from Firestore and add it to the list
          if (doc['image'] != null) {
            fetchedImages.add(doc['image']);
          }
        });

        // Update state with the fetched images
        setState(() {
          images = fetchedImages;
          print(images);
        });
      });
    } catch (e) {
      print("Error fetching post details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            Container(
              height: 1000.h, // Height for the stack
              child: Stack(
                children: [
                  // Background Image
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.isNotEmpty
                        ? images.length
                        : 1, // Length of images array
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // Displaying image from the list of images (if available)
                      String imageUrl = images.isNotEmpty
                          ? images[index]
                          : 'asset/image/weddingphoto.jpg';

                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                imageUrl), // Use NetworkImage for fetched images
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  // Dots Indicator
                  Positioned(
                    top: 280,
                    left: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.isNotEmpty ? images.length : 1,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index
                              ? 12.w
                              : 8.w, // Larger dot for the current index
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Back Button
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 300,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25.r,
                                backgroundImage:
                                    widget.studioDetails['companyLogo'] != null
                                        ? NetworkImage(
                                            widget.studioDetails['companyLogo'])
                                        : null,
                                child:
                                    widget.studioDetails['companyLogo'] == null
                                        ? Text(
                                            'Logo here',
                                            style: TextStyle(fontSize: 8.sp),
                                          )
                                        : null,
                              ),
                              SizedBox(width: 10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.studioDetails['company'],
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.studioDetails['role']} Photographer',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${widget.studioDetails['startingPrice']}',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.yellow, size: 16),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // Address Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  '${widget.studioDetails['addressLine1']}\n${widget.studioDetails['addressLine2']}',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          // Contact Section
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.blue),
                              SizedBox(width: 8.w),
                              Text(
                                widget.studioDetails['phone'],
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ImagePortfolioScreen(
                                                imageUrls: images,
                                              )));
                                },
                                icon: const Icon(Icons.map, color: Colors.white),
                                label: const Text('Portfolio',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // Image Carousel Section

                          // About Us Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About us',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                widget.studioDetails['Description'],
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.sp),
                          // Buttons Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserChatScreen(
                                                studioId: widget.pid!,
                                                studioLogo:
                                                    widget.studioDetails[
                                                        'companyLogo'],
                                                studioName: widget
                                                    .studioDetails['company'],
                                                userId: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                              )));
                                },
                                icon: const Icon(Icons.chat, color: Colors.white),
                                label: const Text('Get in Touch',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserBookingScreen(
                                                studioDetails:
                                                    widget.studioDetails,
                                                studioId: widget.pid!,
                                              )));
                                },
                                icon: const Icon(Icons.book_online,
                                    color: Colors.white),
                                label: const Text(
                                  'Book Now',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  backgroundColor: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
