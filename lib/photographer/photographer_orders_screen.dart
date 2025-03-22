import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotographerOrdersScreen extends StatefulWidget {
  const PhotographerOrdersScreen({super.key});

  @override
  State<PhotographerOrdersScreen> createState() =>
      _PhotographerOrdersScreenState();
}

class _PhotographerOrdersScreenState extends State<PhotographerOrdersScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final ordersQuery = await FirebaseFirestore.instance
        .collection('bookedProducts')
        .where('userId', isEqualTo: currentUserId)
        .get();

    List<Map<String, dynamic>> orders = [];

    for (var order in ordersQuery.docs) {
      var orderData = order.data();
      final productId = orderData['productId'];
      final bookingDate = orderData['bookedDate'] ?? 'No Date';
      final bookingDays =
          int.tryParse(orderData['bookingDays'].toString()) ?? 0;

      if (productId != null) {
        try {
          final productSnapshot = await FirebaseFirestore.instance
              .collection('storeProducts')
              .doc(productId)
              .get();

          if (productSnapshot.exists) {
            final productData = productSnapshot.data() as Map<String, dynamic>;

            List<dynamic> productDetailsArray =
                productData['productDetails'] ?? [];
            if (productDetailsArray.isNotEmpty) {
              var productDetails = productDetailsArray.first;
              orders.add({
                'orderDetails': orderData,
                'productDetails': productDetails,
                'bookingDate': bookingDate,
                'bookingDays': bookingDays,
              });
            }
          }
        } catch (e) {
          print('Error fetching product with ID $productId: $e');
        }
      }
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue[900]),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error fetching data',
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                );
              }

              final orderProducts = snapshot.data ?? [];

              return ListView.builder(
                itemCount: orderProducts.length,
                itemBuilder: (context, index) {
                  final productData = orderProducts[index]['productDetails'];
                  final orderDetails = orderProducts[index]['orderDetails'];

                  final productName = productData['name'] ?? 'No Name';
                  final imageUrl = productData['image'] ?? '';
                  final price =
                      double.tryParse(productData['price'].toString()) ?? 0.0;
                  final bookingDate = orderProducts[index]['bookingDate'];
                  final bookingDays = orderProducts[index]['bookingDays'];

                  final totalPrice = price * bookingDays;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    height: 90.h,
                                    width: 90.w,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 90.h,
                                    width: 90.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Colors.grey[300],
                                    ),
                                    child: Icon(Icons.image_not_supported,
                                        size: 40.sp, color: Colors.grey),
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 4.h),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(FontAwesomeIcons.solidClock,
                                            size: 14.sp, color: Colors.orange),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Duration: $bookingDays days',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(FontAwesomeIcons.solidCalendarDays,
                                            size: 14.sp, color: Colors.blue),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            'Booked On:\n$bookingDate',
                                            style: TextStyle(fontSize: 14.sp),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\₹$totalPrice',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
