import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/photographer/product_booking_screen.dart';
import 'package:photohire/photographer/photographer_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String currentUserId = "";

  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference photographers =
      FirebaseFirestore.instance.collection('photgrapher');

  @override
  void initState() {
    super.initState();
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Stream<DocumentSnapshot> getPhotographerStream() {
    if (currentUserId.isNotEmpty) {
      return photographers.doc(currentUserId).snapshots();
    } else {
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Logo + Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rental Store',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Profile Picture with Navigation
                  StreamBuilder<DocumentSnapshot>(
                    stream: getPhotographerStream(),
                    builder: (context, snapshot) {
                      String companyLogoUrl = "";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        var data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        companyLogoUrl = data['companyLogo'] ?? "";
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PhotographerProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: companyLogoUrl.isNotEmpty
                              ? NetworkImage(companyLogoUrl)
                              : null,
                          child: companyLogoUrl.isEmpty
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    hintText: 'Search for products...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.clear, color: Colors.grey.shade700),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                searchQuery = "";
                              });
                            },
                          )
                        : Icon(Icons.abc_outlined, color: Colors.transparent),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Products Grid
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('storeProducts')
                      .snapshots(),
                  builder: (context, storeProductsSnapshot) {
                    if (storeProductsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (storeProductsSnapshot.hasError) {
                      return Center(
                          child: Text("Error fetching store products"));
                    }
                    if (!storeProductsSnapshot.hasData ||
                        storeProductsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No products found"));
                    }

                    var storeProducts = storeProductsSnapshot.data!.docs;

                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchApprovedRentalStores(storeProducts),
                      builder: (context, rentalStoreSnapshot) {
                        if (rentalStoreSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (rentalStoreSnapshot.hasError) {
                          return Center(
                              child: Text("Error fetching rental stores"));
                        }
                        if (!rentalStoreSnapshot.hasData ||
                            rentalStoreSnapshot.data!.isEmpty) {
                          return Center(
                              child: Text("No approved rental stores found"));
                        }

                        var approvedProducts = storeProducts.where((product) {
                          var userId = product['userId'];
                          return rentalStoreSnapshot.data!
                              .any((rentalStore) => rentalStore.id == userId);
                        }).toList();

                        // Apply search filter
                        var filteredProducts =
                            approvedProducts.where((product) {
                          var productDetails =
                              product['productDetails'] as List<dynamic>;
                          if (productDetails.isNotEmpty) {
                            var productName = productDetails[0]['name']
                                .toString()
                                .toLowerCase();
                            return productName.contains(searchQuery);
                          }
                          return false;
                        }).toList();

                        if (filteredProducts.isEmpty) {
                          return Center(
                              child: Text("No matching products found"));
                        }

                        return GridView.builder(
                          padding: EdgeInsets.only(top: 10.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            var product = filteredProducts[index].data()
                                as Map<String, dynamic>;
                            var productDetails =
                                product['productDetails'] as List<dynamic>;

                            if (productDetails.isNotEmpty) {
                              var firstProductDetail = productDetails[0];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductBookingScreen(
                                        productId: filteredProducts[index].id,
                                        productName: firstProductDetail['name'],
                                        image: firstProductDetail['image'],
                                        desc: firstProductDetail['description'],
                                        rating: 0.0,
                                        price: firstProductDetail['price']
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15.r)),
                                        child: Image.network(
                                          firstProductDetail['image'] ?? '',
                                          height: 120.h,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.w),
                                        child: Text(
                                          firstProductDetail['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchApprovedRentalStores(
      List<QueryDocumentSnapshot> storeProducts) async {
    var userIds = storeProducts.map((e) => e['userId']).toSet();
    var querySnapshot = await FirebaseFirestore.instance
        .collection('rentalStore')
        .where(FieldPath.documentId, whereIn: userIds.toList())
        .where('isApproved', isEqualTo: true)
        .get();

    return querySnapshot.docs;
  }
}
