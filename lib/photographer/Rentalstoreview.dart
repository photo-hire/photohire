import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/customwidgets/explore_screen_widget.dart';
import 'package:photohire/photographer/product_booking_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();

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
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rental Store',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('storeProducts') // Your collection name
                        .snapshots(), // Listen for real-time updates
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

                      // Fetch all store products
                      var storeProducts = storeProductsSnapshot.data!.docs;

                      // Fetch rentalStore data for isApproved field check
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

                          // Get approved store products
                          var approvedProducts = storeProducts.where((product) {
                            var userId = product['userId'];
                            return rentalStoreSnapshot.data!
                                .any((rentalStore) => rentalStore.id == userId);
                          }).toList();

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: .9),
                            itemCount: approvedProducts.length,
                            itemBuilder: (context, index) {
                              var product = approvedProducts[index].data()
                                  as Map<String, dynamic>;
                              var productDetails =
                                  product['productDetails'] as List<dynamic>;

                              if (productDetails.isNotEmpty) {
                                var firstProductDetail =
                                    productDetails[0]; // First detail

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductBookingScreen(
                                                  productId:
                                                      approvedProducts[index]
                                                          .id,
                                                  productName:
                                                      firstProductDetail[
                                                          'name'],
                                                  image: firstProductDetail[
                                                      'image'],
                                                  desc: firstProductDetail[
                                                      'description'],
                                                  rating: 0.0,
                                                  price: firstProductDetail[
                                                          'price']
                                                      .toString(),
                                                )));
                                  },
                                  child: ExploreScreenWidget(
                                    image: firstProductDetail['image'] ??
                                        'asset/image/weddingphoto.jpg',
                                    title: firstProductDetail['name'] ??
                                        'No Title',
                                    price: firstProductDetail['price']
                                            .toString() ??
                                        '0.0',
                                    rating: firstProductDetail['rating'] ?? 0.0,
                                  ),
                                );
                              } else {
                                return Center(
                                    child:
                                        Text("No product details available"));
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
