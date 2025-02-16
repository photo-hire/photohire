import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchRentalAndBookedProducts() async {
    final rentalProductsQuery = await FirebaseFirestore.instance
        .collection('storeProducts')
        .where('userId', isEqualTo: currentUserId)
        .get();

    List<Map<String, dynamic>> rentalProducts = [];
    for (var rentalProduct in rentalProductsQuery.docs) {
      final productId = rentalProduct.id;
      final bookedProductQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: productId)
          .get();

      if (bookedProductQuery.docs.isNotEmpty) {
        for (var bookedProduct in bookedProductQuery.docs) {
          // Get userId from booked product and fetch user data
          final userId = bookedProduct['userId'];
          final userQuery = await FirebaseFirestore.instance
              .collection('photgrapher') // Assuming user data is stored in 'users' collection
              .doc(userId)
              .get();

          if (userQuery.exists) {
            final userData = userQuery.data();
            
            Map<String, dynamic> productData = rentalProduct.data();

            productData['productId'] = productId;
            
            productData['userData'] = userData; // Add user data to the product data
            
            productData['bookingDays'] = bookedProduct['bookingDays'];
            
            productData['bookingDate'] = bookedProduct['bookedDate'];
            productData['bookedToDate'] = bookedProduct['bookedToDate'];

            rentalProducts.add(productData);
          }
        }
      }
    }
    return rentalProducts;
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
            padding: const EdgeInsets.fromLTRB(15, 60, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>( 
                    future: fetchRentalAndBookedProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error fetching data'));
                      }
                      if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Center(child: Text('No orders found'));
                      }

                      final rentalProducts = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: rentalProducts.length,
                        itemBuilder: (context, index) {
                          final productData = rentalProducts[index];
                          final userData = productData['userData'] ?? {};
                          final userName = userData['name'] ?? 'No Name';
                          final productName = productData['productDetails'][0]['name'] ?? 'No Name';
                          final price = productData['productDetails'][0]['price'] ?? 'No Price';
                          final imageUrl = productData['productDetails'][0]['image'] ?? '';
                          final bookingDays = productData['bookingDays'] ?? '0';
                          final bookingDate = productData['bookingDate'] ?? 'No Date';
                          final bookedToDate = productData['bookedToDate']??'No Date';

                          return Container(
                            width: double.infinity,
                            height: 100.h,
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.image_not_supported),
                                ),
                                SizedBox(width: 10.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      userName, // Show username instead of product name
                                      style: TextStyle(fontSize: 18.sp),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Product: $productName'),
                                    SizedBox(height: 5),
                                    Text('Booking Days: $bookingDays'),
                                    SizedBox(height: 5),
                                    Text('Booked To: $bookedToDate'),
                                  ],
                                ),
                              ],
                            ),
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
}
