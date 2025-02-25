import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Razorpay package
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package

class UserProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String pid;

  const UserProductDetailsScreen({Key? key, required this.product, required this.pid})
      : super(key: key);

  @override
  _UserProductDetailsScreenState createState() =>
      _UserProductDetailsScreenState();
}

class _UserProductDetailsScreenState extends State<UserProductDetailsScreen> {
  late Razorpay _razorpay;
  DateTime? _startDate;
  DateTime? _endDate;
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

  Future<void> _saveOrderDetails(String paymentId) async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select valid dates.')),
      );
      return;
    }

    // Prepare order data
    Map<String, dynamic> orderData = {
      "bookedDate": DateFormat('yyyy-MM-dd').format(_startDate!),
      "bookedToDate": DateFormat('yyyy-MM-dd').format(_endDate!),
      "product": widget.product['name'] ?? 'Unnamed Product',
      "productId": widget.pid, // Assuming product has an 'id' field
      "userId": FirebaseAuth.instance.currentUser!.uid, // Replace with actual user ID
      "paymentId": paymentId,
      "amount": widget.product['price'] * _calculateDays(), // Total amount
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

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }


Future<bool> _checkIfDatesAreBooked() async {
  if (_startDate == null || _endDate == null) return false;

  // Convert _startDate and _endDate to just date (no time)
  DateTime startDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
  DateTime endDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('productId', isEqualTo: widget.pid)
      .get();

  for (var doc in snapshot.docs) {
    print(doc.data());

    DateTime bookedDate;
    DateTime bookedToDate;

    if (doc['bookedDate'] is Timestamp) {
      bookedDate = (doc['bookedDate'] as Timestamp).toDate();
      bookedToDate = (doc['bookedToDate'] as Timestamp).toDate();
    } else {
      bookedDate = DateFormat('yyyy-MM-dd').parse(doc['bookedDate']);
      bookedToDate = DateFormat('yyyy-MM-dd').parse(doc['bookedToDate']);
    }

    // Convert Firestore dates to date-only (ignore time)
    bookedDate = DateTime(bookedDate.year, bookedDate.month, bookedDate.day);
    bookedToDate = DateTime(bookedToDate.year, bookedToDate.month, bookedToDate.day);

    print(startDate.isAtSameMomentAs(bookedDate));

    print('====================++++');

    // Check if selected dates overlap with booked dates
    if ((startDate.isAfter(bookedDate) && startDate.isBefore(bookedToDate)) ||
        (endDate.isAfter(bookedDate) && endDate.isBefore(bookedToDate)) ||
        (startDate.isBefore(bookedDate) && endDate.isAfter(bookedToDate)) ||
        (startDate.isAtSameMomentAs(bookedDate) || endDate.isAtSameMomentAs(bookedToDate))) {
      print('Dates are already booked!');
      return true;
    }
  }

  return false;
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
                SizedBox(height: 100), // Extra space for the button at the bottom
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
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Book Photographer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Date Picker
                  ListTile(
                    title: Text('Start Date'),
                    subtitle: Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : DateFormat('yyyy-MM-dd').format(_startDate!),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _startDate = pickedDate;
                          _endDate = null; // Reset end date
                        });
                      }
                    },
                  ),
                  // End Date Picker
                  ListTile(
                    title: Text('End Date'),
                    subtitle: Text(
                      _endDate == null
                          ? 'Select End Date'
                          : DateFormat('yyyy-MM-dd').format(_endDate!),
                    ),
                    onTap: () async {
                      if (_startDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a start date first.')),
                        );
                        return;
                      }

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate!,
                        firstDate: _startDate!,
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _endDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),


          TextButton(
            onPressed: () async {
              if (_startDate == null || _endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select both start and end dates.')),
                );
                return;
              }

              if (_endDate!.isBefore(_startDate!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('End date must be after start date.')),
                );
                return;
              }

              bool isBooked = await _checkIfDatesAreBooked();

              print('------------------booked----------------');

              print(isBooked);
              if (isBooked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected dates are already booked.')),
                );
                return;
              }

              int amount = int.parse(widget.product['price']) * _calculateDays();
              _openRazorpayGateway(amount); // Open Razorpay payment gateway
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Proceed to Pay',
                style: TextStyle(color: Colors.blueAccent)),
          ),
       
       
              
             
              ],
            );
          },
        );
      },
    );
  }




}





