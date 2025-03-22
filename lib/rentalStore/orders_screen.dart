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

  Future<Map<String, List<Map<String, dynamic>>>> fetchOrders() async {
    List<Map<String, dynamic>> bookedProducts = [];
    List<Map<String, dynamic>> rentalOrders = [];

    // Fetch booked products
    final bookedProductsQuery = await FirebaseFirestore.instance
        .collection('bookedProducts')
        .where('ownerId', isEqualTo: currentUserId)
        .get();

    for (var doc in bookedProductsQuery.docs) {
      bookedProducts.add({
        'productName': doc['product'],
        'productId': doc['productId'],
        'userName': doc['userName'],
        'bookingDays': doc['bookingDays'],
        'bookedDate': doc['bookedDate'],
        'bookedToDate': doc['bookedToDate'],
      });
    }

    // Fetch rental orders
    final rentalOrdersQuery = await FirebaseFirestore.instance
        .collection('orders')
        .where('ownerId', isEqualTo: currentUserId)
        .get();

    for (var doc in rentalOrdersQuery.docs) {
      rentalOrders.add({
        'productName': doc['product'],
        'productId': doc['productId'],
        'status': doc['status'],
        'amount': doc['amount'],
        'bookedDate': doc['bookedDate'],
        'bookedToDate': doc['bookedToDate'],
        'paymentId': doc['paymentId'],
      });
    }

    return {'bookedProducts': bookedProducts, 'rentalOrders': rentalOrders};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orders',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(15.w),
          child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
            future: fetchOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error fetching data'));
              }

              final bookedProducts = snapshot.data?['bookedProducts'] ?? [];
              final rentalOrders = snapshot.data?['rentalOrders'] ?? [];

              return ListView(
                children: [
                  if (bookedProducts.isNotEmpty) ...[
                    Text('Booked Products',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.h),
                    ...bookedProducts
                        .map((data) => OrderTile(data: data))
                        .toList(),
                  ],
                  if (rentalOrders.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Text('Rental Orders',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.h),
                    ...rentalOrders
                        .map((data) => OrderTile(data: data))
                        .toList(),
                  ],
                  if (bookedProducts.isEmpty && rentalOrders.isEmpty)
                    Center(
                        child: Text('No orders found',
                            style: TextStyle(fontSize: 16.sp))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const OrderTile({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['productName'] ?? 'No Name',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 5.h),
            if (data.containsKey('userName'))
              Text('Booked by: ${data['userName']}',
                  style: TextStyle(fontSize: 14.sp)),
            if (data.containsKey('status'))
              Text('Status: ${data['status']}',
                  style: TextStyle(fontSize: 14.sp)),
            if (data.containsKey('amount'))
              Text('Amount: ₹${data['amount']}',
                  style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 5.h),
            Text('Booked Date: ${data['bookedDate']}',
                style: TextStyle(fontSize: 14.sp)),
            Text('Booked To: ${data['bookedToDate']}',
                style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
