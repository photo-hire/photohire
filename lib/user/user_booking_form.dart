import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> studioDetails;
  final String studioId;

  const BookingForm({
    super.key,
    required this.studioDetails,
    required this.studioId,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late Razorpay _razorpay;
  int _price = 0; // Store price dynamically

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

  // Fetch Photographer's Price from Firestore
  Future<void> _fetchPrice() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(widget.studioId)
          .get();
      setState(() {
        _price =
            (doc['startingPrice'] as num).toInt() * 100; // Convert ₹ to paisa
      });
    } catch (e) {
      debugPrint('Error fetching price: $e');
    }
  }

  // Select Date
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

  // Select Time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // Check for existing bookings
  Future<bool> _isAlreadyBooked() async {
    QuerySnapshot bookingQuery = await FirebaseFirestore.instance
        .collection('photographerbookings')
        .where('studio', isEqualTo: widget.studioId)
        .where('date',
            isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate!))
        .get();

    return bookingQuery.docs.isNotEmpty;
  }

  // Proceed to Payment
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
      'key': 'rzp_test_QLvdqmBfoYL2Eu', // Replace with actual Razorpay Key
      'amount': _price, // Use dynamically fetched price
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

  // Handle Payment Success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _submitBooking(response.paymentId);
  }

  // Handle Payment Failure
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: Colors.red),
    );
  }

  // Handle External Wallet Selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  // Submit Booking after Payment
  Future<void> _submitBooking(String? paymentId) async {
    await FirebaseFirestore.instance.collection('photographerbookings').add({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _selectedTime!.format(context),
      'notes': _notesController.text,
      'studio': widget.studioId,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'paymentId': paymentId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Booking Successful!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100.h),
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
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: _buildContainer(
          Icons.calendar_today,
          _selectedDate == null
              ? 'Choose a date'
              : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: _buildContainer(
          Icons.access_time,
          _selectedTime == null
              ? 'Choose a time'
              : _selectedTime!.format(context)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildContainer(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(children: [Icon(icon), SizedBox(width: 16.w), Text(text)]),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: _proceedToPayment, child: Text('Proceed to Payment')),
    );
  }
}
