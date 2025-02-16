import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> studioDetails;
  final String studioId;

  const BookingForm({super.key, required this.studioDetails, required this.studioId});

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

  // Select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Select Time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // Submit Booking
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red));
      return;
    }
    
    final success = await BookingService.submitBooking(
      studioId: widget.studioId,
      name: _nameController.text,
      phone: _phoneController.text,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      time: _selectedTime!.format(context),
      notes: _notesController.text,
      context: context,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Successful!'), backgroundColor: Colors.green));
    }
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
            _buildStudioDetails(),
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
    );
  }

  Widget _buildStudioDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: widget.studioDetails['companyLogo'] != null ? NetworkImage(widget.studioDetails['companyLogo']) : null,
              child: widget.studioDetails['companyLogo'] == null ? Icon(Icons.camera_alt, size: 30.r) : null,
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.studioDetails['company'], style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text('${widget.studioDetails['role']} Photographer', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: _buildContainer(Icons.calendar_today, _selectedDate == null ? 'Choose a date' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: _buildContainer(Icons.access_time, _selectedTime == null ? 'Choose a time' : _selectedTime!.format(context)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)), filled: true, fillColor: Colors.white.withOpacity(0.9)),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildContainer(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))]),
      child: Row(children: [Icon(icon, color: Colors.blue[900]), SizedBox(width: 16.w), Text(text, style: TextStyle(fontSize: 16.sp))]),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: _submitBooking, child: const Text('Submit Booking')),
    );
  }
}




class BookingService {
  static Future<bool> submitBooking({required String studioId, required String name, required String phone, required String date, required String time, required String notes, required BuildContext context}) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('photographerbookings').where('studio', isEqualTo: studioId).where('date', isEqualTo: date).where('time', isEqualTo: time).get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time slot already booked!'), backgroundColor: Colors.red));
      return false;
    }

    await FirebaseFirestore.instance.collection('photographerbookings').add({'name': name, 'phone': phone, 'date': date, 'time': time, 'notes': notes, 'studio': studioId, 'userId': FirebaseAuth.instance.currentUser!.uid});
    return true;
  }
}


