import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Razorpay package
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package

class UserProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const UserProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _UserProductDetailsScreenState createState() =>
      _UserProductDetailsScreenState();
}

class _UserProductDetailsScreenState extends State<UserProductDetailsScreen> {
  late Razorpay _razorpay;
  int _bookingDays = 0;
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear Razorpay listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success logic
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );

    // Save order details after successful payment
    _saveOrderDetails(response.paymentId!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failure logic
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet logic
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpayGateway(int amount) {
    setState(() {
      _isLoading = true; // Start loading
    });

    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu', // Replace with your Razorpay API Key
      'amount': amount * 100, // Amount in paise (e.g., 1000 = ₹10)
      'name': 'Product Booking',
      'description': 'Booking for ${widget.product['name']}',
      'prefill': {'contact': '1234567890', 'email': 'user@example.com'},
      'external': {
        'wallets': ['paytm'] // Optional: External wallets
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      print('Error: $e');
    }
  }

  void _saveOrderDetails(String paymentId) async {
    // Get the current date
    DateTime now = DateTime.now();
    String bookedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the end date
    DateTime bookedToDate = now.add(Duration(days: _bookingDays));
    String bookedToDateFormatted =
        DateFormat('yyyy-MM-dd').format(bookedToDate);

    // Prepare order data
    Map<String, dynamic> orderData = {
      "bookedDate": bookedDate,
      "bookedToDate": bookedToDateFormatted,
      "bookingDays": _bookingDays.toString(),
      "product": widget.product['name'] ?? 'Unnamed Product',
      "productId":
          widget.product['id'] ?? '', // Assuming product has an 'id' field
      "userId":
          FirebaseAuth.instance.currentUser!.uid, // Replace with actual user ID
      // Replace with actual user name
      "paymentId": paymentId,
      "amount": widget.product['price'] * _bookingDays, // Total amount
      "status": "Booked", // Order status
    };

    // Save order to Firestore
    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      setState(() {
        _isLoading = false; // Stop loading
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.product['image'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, size: 50, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                // Product Name
                Text(
                  widget.product['name'] ?? 'Unnamed Product',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                // Divider
                Divider(color: Colors.grey[300], thickness: 1),
                SizedBox(height: 8),
                // Product Description
                Text(
                  widget.product['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                // Divider
                Divider(color: Colors.grey[300], thickness: 1),
                SizedBox(height: 16),
                // Product Price
                Text(
                  'Price: ₹${widget.product['price'] ?? '0.00'}', // Indian Rupee symbol
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                    height: 100), // Extra space for the button at the bottom
              ],
            ),
          ),
          // Book the Product Button at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isLoading) {
                    _showBookingDialog(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white) // Show loading indicator
                      : Text(
                          'Book the Product',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    TextEditingController daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the number of days to book:'),
            SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 5',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (daysController.text.isNotEmpty) {
                _bookingDays = int.parse(daysController.text);
                int amount = int.parse(widget.product['price']) *
                    _bookingDays; // Calculate total amount
                _openRazorpayGateway(amount); // Open Razorpay payment gateway
                Navigator.pop(context); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter the number of days.')),
                );
              }
            },
            child: Text('Proceed to Pay',
                style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
