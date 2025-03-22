import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductBookingScreen extends StatefulWidget {
  final String productName;
  final String image;
  final String desc;
  final String price;
  final String productId;

  ProductBookingScreen({
    super.key,
    required this.price,
    required this.productId,
    required this.productName,
    required this.image,
    required this.desc,
  });

  @override
  State<ProductBookingScreen> createState() => _ProductBookingScreenState();
}

class _ProductBookingScreenState extends State<ProductBookingScreen> {
  TextEditingController bookingDaysController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  Razorpay? _razorpay;
  bool isLoading = false;
  String userName = "Guest"; // Store the user's name

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _loadCurrentUserName();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _loadCurrentUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('photgrapher') // Ensure the collection name is correct
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? 'Guest';
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      String bookingDays = bookingDaysController.text.trim();
      String bookedToDate = _dateController.text.trim();

      await FirebaseFirestore.instance.collection('bookedProducts').add({
        'userId': userId,
        'userName': userName,
        'productId': widget.productId,
        'product': widget.productName,
        'bookingDays': bookingDays,
        'bookedDate': DateTime.now().toLocal().toIso8601String().split('T')[0],
        'bookedToDate': bookedToDate,
        'paymentId': response.paymentId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful! Booking Confirmed')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error saving booking: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  void _startPayment() async {
    String bookingDaysText = bookingDaysController.text.trim();
    DateTime selectedStartDate = _selectedDate;
    int bookingDays = int.tryParse(bookingDaysText) ?? 1;
    DateTime selectedEndDate =
        selectedStartDate.add(Duration(days: bookingDays - 1));

    if (bookingDaysText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the number of days')),
      );
      return;
    }

    // Check if a booking exists for the selected date range
    var existingBookings = await FirebaseFirestore.instance
        .collection('bookedProducts')
        .where('productId', isEqualTo: widget.productId)
        .get();

    for (var doc in existingBookings.docs) {
      DateTime bookedStartDate = DateTime.parse(doc['bookedDate']);
      DateTime bookedEndDate = DateTime.parse(doc['bookedToDate']);

      // Check if the selected booking dates overlap with existing bookings
      if (!(selectedEndDate.isBefore(bookedStartDate) ||
          selectedStartDate.isAfter(bookedEndDate))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'This product is already booked for the selected date range.')),
        );
        return;
      }
    }

    double pricePerDay = double.parse(widget.price);
    double totalAmount = pricePerDay * bookingDays * 100; // Convert to paisa

    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu', // Replace with your Razorpay Key
      'amount': totalAmount.toInt(), // Amount must be an integer
      'name': 'PhotoHire',
      'description': 'Booking ${widget.productName} for $bookingDays days',
      'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                widget.productName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.desc,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10.h),
              Text(
                '\₹${widget.price}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Book the product'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: bookingDaysController,
                              decoration: InputDecoration(
                                labelText: 'No of days',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: InputDecoration(
                                labelText: 'Select Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _startPayment();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    'Proceed to Pay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text('Book Now',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
