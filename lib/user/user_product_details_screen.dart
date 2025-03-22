import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String name;
  final String image;
  final String desc;
  final String price;
  final String userId;

  UserProductDetailsScreen({
    Key? key,
    required this.productId,
    required this.name,
    required this.image,
    required this.desc,
    required this.price,
    required this.userId,
  }) : super(key: key);

  @override
  _UserProductDetailsScreenState createState() =>
      _UserProductDetailsScreenState();
}

class _UserProductDetailsScreenState extends State<UserProductDetailsScreen> {
  late Razorpay _razorpay;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openRazorpayGateway() {
    if (!_formKey.currentState!.validate()) return;
    double amount =
        double.parse(widget.price) * int.parse(_daysController.text) * 100;

    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu',
      'amount': amount.toInt(),
      'name': widget.name,
      'description': 'Product Rental for ${_daysController.text} days',
      'prefill': {
        'contact': _phoneController.text,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    FirebaseFirestore.instance.collection('orders').add({
      'amount': widget.price,
      'bookedDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'bookedToDate': DateFormat('yyyy-MM-dd').format(
          _selectedDate!.add(Duration(days: int.parse(_daysController.text)))),
      'paymentId': response.paymentId,
      'product': widget.name,
      'productId': widget.productId,
      'status': 'Booked',
      'userId': widget.userId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
              child: Text("Enter Booking Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.length < 10 ? "Enter a valid phone number" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _daysController,
                  decoration: InputDecoration(
                    labelText: "Number of days",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      int.tryParse(value!) == null ? "Enter valid days" : null,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Text(_selectedDate == null
                      ? "Select Start Date"
                      : "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _openRazorpayGateway();
                }
              },
              child: Text("Proceed to Payment"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(widget.image,
                    height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: ₹${widget.price}/day",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700])),
                      if (widget.desc.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(widget.desc,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700])),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _showBookingDialog,
                  child: Text("Rent Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
