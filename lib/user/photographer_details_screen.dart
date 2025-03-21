import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Add this import
import 'package:geocoding/geocoding.dart';
import 'package:photohire/user/booking_photographers_screen.dart';
import 'package:photohire/user/portfolio_screen.dart';
import 'package:photohire/user/user_chat_screen.dart';

class PhotographerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> studioDetails;
  final String? pid;

  PhotographerDetailsScreen({
    Key? key,
    required this.studioDetails,
    required this.pid,
  }) : super(key: key);

  @override
  State<PhotographerDetailsScreen> createState() =>
      _PhotographerDetailsScreenState();
}

class _PhotographerDetailsScreenState extends State<PhotographerDetailsScreen> {
  List<String> images = []; // List to hold image URLs
  late PageController _pageController;
  int _currentIndex = 0;
  List<Map<String, dynamic>> reviews = []; // List to hold reviews

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchPostDetails(); // Fetch the post details when the screen is initialized
    _fetchReviews(); // Fetch reviews when the screen is initialized
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fetch post details from Firestore
  Future<void> _fetchPostDetails() async {
    try {
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: widget.pid) // Filter by userId
          .get()
          .then((querySnapshot) {
        List<String> fetchedImages = [];
        querySnapshot.docs.first['postDetails'].forEach((doc) {
          if (doc['image'] != null) {
            fetchedImages.add(doc['image']);
          }
        });

        setState(() {
          images = fetchedImages;
        });
      });
    } catch (e) {
      print("Error fetching post details: $e");
    }
  }

  double rating = 0.0;

  // Fetch reviews from Firestore
  Future<void> _fetchReviews() async {
    try {
      FirebaseFirestore.instance
          .collection('reviews')
          .where('studioId', isEqualTo: widget.pid) // Filter by studioId
          .get()
          .then((querySnapshot) {
        List<Map<String, dynamic>> fetchedReviews = [];
        double totalRating = 0.0;
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) {
            fetchedReviews.add(doc.data());
            // rating += doc['rating'];
            totalRating += doc['rating'];
          });
          rating = totalRating / fetchedReviews.length;
        }

        setState(() {
          reviews = fetchedReviews;
          print('---------------------');
          print(reviews);
          print(rating);
        });
      });
    } catch (e) {
      print("Error fetching reviews: $e");
    }
  }

  // Submit a review to Firestore
  Future<void> _submitReview(String reviewText, double rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String userName = 'Anonymous'; // Default name
        String profileImage = ''; // Default name
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] ?? 'Anonymous';
          profileImage = userDoc.data()?['profileImage'] ?? '';
        }

        final reviewData = {
          'userId': user.uid,
          'userName': userName,
          'reviewText': reviewText,
          'rating': rating,
          'timestamp': DateTime.now(),
          'studioId': widget.pid,
          'image': profileImage
        };

        await FirebaseFirestore.instance.collection('reviews').add(reviewData);
        _fetchReviews(); // Refresh the reviews after submission
      }
    } catch (e) {
      print("Error submitting review: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Section
            Container(
              height: 1000.h, // Height for the stack
              child: Stack(
                children: [
                  // Background Image
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.isNotEmpty ? images.length : 1,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      String imageUrl = images.isNotEmpty
                          ? images[index]
                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdASyvwmzMDS7ddjV87hv1QW1K3OWL05JHuw&s';

                      return Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.fitHeight,
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
                          width: _currentIndex == index ? 12.w : 8.w,
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
                                    '\₹${widget.studioDetails['startingPrice']}',
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
                                        rating.toString(),
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
                              FutureBuilder<String>(
                                future: _getAddressFromCoordinates(
                                  widget.studioDetails['latitude'],
                                  widget.studioDetails['longitude'],
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    return Expanded(
                                      child: Text(
                                        snapshot.data!,
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    );
                                  } else {
                                    return Text('No address available');
                                  }
                                },
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
                                icon:
                                    const Icon(Icons.map, color: Colors.white),
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
                          // About Us Section
                          Align(
                            alignment: Alignment.topLeft,
                            child: Column(
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
                                          builder: (context) => ChatScreen(
                                                receiverId: widget.pid!,
                                                senderId: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userName: widget
                                                    .studioDetails['company'],
                                              )));
                                },
                                icon:
                                    const Icon(Icons.chat, color: Colors.white),
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
                          SizedBox(height: 16.h),
                          // Reviews Section
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ListView(
                                children: [
                                  Text(
                                    'Reviews',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  reviews.isEmpty
                                      ? Text(
                                          'No reviews yet.',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey),
                                        )
                                      : Column(
                                          children: reviews.map((review) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage:
                                                    review['image'] != null ||
                                                            review['image'] !=
                                                                ''
                                                        ? NetworkImage(
                                                            review['image'])
                                                        : null,
                                              ),
                                              title: Text(review['userName']),
                                              subtitle:
                                                  Text(review['reviewText']),
                                              trailing: RatingBar.builder(
                                                initialRating: review['rating'],
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 16,
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                ignoreGestures:
                                                    true, // Disable user interaction
                                                onRatingUpdate: (rating) {},
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 11, 86, 147),
                                      ),
                                      onPressed: () {
                                        _showReviewDialog();
                                      },
                                      child: Text(
                                        'Add Review',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  // Show a dialog to submit a review
  void _showReviewDialog() {
    TextEditingController reviewController = TextEditingController();
    double rating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration: InputDecoration(hintText: 'Enter your review'),
              ),
              SizedBox(height: 16.h),
              Text('Rating'),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitReview(reviewController.text, rating);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

Future<String> _getAddressFromCoordinates(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
  } catch (e) {
    print("Error getting address: $e");
    return "Unknown Address";
  }
}
