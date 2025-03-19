import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserBookingScreen extends StatefulWidget {
  final Map<String, dynamic> studioDetails;
  final String studioId;

  const UserBookingScreen({
    super.key,
    required this.studioDetails,
    required this.studioId,
  });

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late Razorpay _razorpay;
  int _price = 0;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(widget.studioId)
          .get();
      setState(() {
        _price = (doc['startingPrice'] as num).toInt() * 100;
      });
    } catch (e) {
      debugPrint('Error fetching price: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<bool> _isAlreadyBooked() async {
    QuerySnapshot bookingQuery = await FirebaseFirestore.instance
        .collection('photographerbookings')
        .where('studio', isEqualTo: widget.studioId)
        .where('date',
            isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate!))
        .get();

    return bookingQuery.docs.isNotEmpty;
  }

  void _proceedToPayment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Colors.red));
      return;
    }

    if (await _isAlreadyBooked()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This date is already booked! Choose another.'),
          backgroundColor: Colors.orange));
      return;
    }

    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu',
      'amount': _price,
      'name': widget.studioDetails['company'],
      'description': 'Photography Booking',
      'prefill': {
        'contact': _phoneController.text,
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _submitBooking(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  Future<void> _submitBooking(String? paymentId) async {
    await FirebaseFirestore.instance.collection('photographerbookings').add({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _formatTime(_selectedTime!),
      'notes': _notesController.text,
      'studio': widget.studioId,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'paymentId': paymentId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Booking Successful!'), backgroundColor: Colors.green),
    );

    // Navigate back to PhotographerDetailsScreen
    Navigator.pop(context);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate == null
              ? 'Choose a date'
              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Time',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Text(
          _selectedTime == null ? 'Choose a time' : _formatTime(_selectedTime!),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Book ${widget.studioDetails['company']}',
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(11),
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249),
              Color.fromARGB(255, 162, 213, 255),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              _buildStudioCard(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    _buildDateSelector(),
                    SizedBox(height: 24.h),
                    _buildTimeSelector(),
                    SizedBox(height: 24.h),
                    _buildTextField(_nameController, 'Name', Icons.person),
                    SizedBox(height: 16.h),
                    _buildTextField(_phoneController, 'Phone', Icons.phone),
                    SizedBox(height: 16.h),
                    _buildTextField(_notesController, 'Notes', Icons.note),
                    SizedBox(height: 24.h),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToPayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        child: Text(
          'Proceed to Pay',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStudioCard() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.studioDetails['companyLogo']),
        ),
        title: Text(widget.studioDetails['company']),
        subtitle: Text('Price: ₹${_price ~/ 100}'),
      ),
    );
  }
}
