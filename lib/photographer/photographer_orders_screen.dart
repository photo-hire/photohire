import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotographerOrdersScreen extends StatefulWidget {
  const PhotographerOrdersScreen({super.key});

  @override
  State<PhotographerOrdersScreen> createState() => _PhotographerOrdersScreenState();
}

class _PhotographerOrdersScreenState extends State<PhotographerOrdersScreen> {

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

Future<List<Map<String, dynamic>>> fetchOrders() async {
  // Fetch the orders for the current user
  final ordersQuery = await FirebaseFirestore.instance
      .collection('bookedProducts')
      .where('userId', isEqualTo: currentUserId)
      .get();

  List<Map<String, dynamic>> orders = [];

  for (var order in ordersQuery.docs) {
    var orderData = order.data();

    // Retrieve the product ID from the order document
    final productId = orderData['productId'];

    if (productId != null) {
      try {
        // Fetch the product details from the storeProducts collection
        final productSnapshot = await FirebaseFirestore.instance
            .collection('storeProducts')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          final productData = productSnapshot.data() as Map<String, dynamic>;

          // Combine the order data with the product data
          orders.add({
            'orderDetails': orderData,
            'productDetails': productData,
          });
        } else {
          print('Product with ID $productId does not exist');
        }
      } catch (e) {
        print('Error fetching product with ID $productId: $e');
      }
    } else {
      print('No product ID found in order: ${order.id}');
    }
  }

  return orders;
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
                    future: fetchOrders(),
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

                      final orderProducts = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: orderProducts.length,
                        itemBuilder: (context, index) {
                          final productData = orderProducts[index];
                          final productName = productData['productDetails']['productDetails'][0]['name'] ?? 'No Name';
                          final price = productData['productDetails']['productDetails'][0]['price'] ?? 'No Price';
                          final imageUrl = productData['productDetails']['productDetails'][0]['image'] ?? '';
                          final bookingDays = productData['orderDetails']['bookingDays'] ?? '0';
                          final bookingDate = productData['orderDetails']['bookingDate'] ?? 'No Date';
                          final bookedToDate = productData['orderDetails']['bookedToDate']??'No Date';

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
                                      productName, // Show username instead of product name
                                      style: TextStyle(fontSize: 18.sp),
                                    ),
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