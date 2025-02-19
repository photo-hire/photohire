import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ProductBookingScreen extends StatefulWidget {
  String productName;
  String image;
  String desc;
  double rating;
  String price;
  String productId;
  ProductBookingScreen(
      {super.key,
      required this.price,
      required this.productId,
      required this.rating,
      required this.productName,
      required this.image,
      required this.desc});

  @override
  State<ProductBookingScreen> createState() => _ProductBookingScreenState();
}

class _ProductBookingScreenState extends State<ProductBookingScreen> {
  TextEditingController userController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController bookingDaysController = TextEditingController();
  bool isLoading = false;
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Initial selected date
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isBooked = false;

  @override
  void initState() {
    super.initState();
    // Set the initial text to the current date
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    productController.text = widget.productName;
    _loadCurrentUserName();
    getBookedStatus(widget.productId, userId);
  }

  Future<void> getBookedStatus(String productId, String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookedProducts')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        isBooked = true;
        setState(() {});
      } else {
        isBooked = false;
        setState(() {});
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadCurrentUserName() async {
    try {
      // Fetch the user's document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(userId)
          .get();

      // Check if the document exists and update the userController text
      if (userDoc.exists) {
        final userName = userDoc.data()?['name'] ??
            'Guest'; // Default to 'Guest' if the name is not present
        setState(() {
          userController.text = userName;
        });
      } else {
        userController.text = 'Guest';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      userController.text = 'Error';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Current selected date
      firstDate: DateTime(2000), // Earliest date allowed
      lastDate: DateTime(2100), // Latest date allowed
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 3,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.image),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.productName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${widget.rating}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            widget.desc,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            '\₹${widget.price}',
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: Colors.blue[900]),
                            child: TextButton(
                              onPressed: () {
                                isBooked
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text('Already Booked')))
                                    : showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setDialogState) {
                                              return AlertDialog(
                                                title: Text('Book the product'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          productController,
                                                      decoration: InputDecoration(
                                                          labelText: 'Product',
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r))),
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                    ),
                                                    TextField(
                                                      controller:
                                                          userController,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                              'Your name',
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r))),
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                    ),
                                                    TextField(
                                                      controller:
                                                          bookingDaysController,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                              'No of days you want to book',
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r))),
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                    ),
                                                    TextField(
                                                      controller:
                                                          _dateController,
                                                      readOnly:
                                                          true, // Make the TextField non-editable
                                                      onTap: () => _selectDate(
                                                          context), // Show date picker on tap
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Select Date',
                                                        hintText: 'yyyy-MM-dd',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.r)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 24.h,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        try {
                                                          isLoading = true;
                                                          setDialogState(() {});

                                                          String product =
                                                              productController
                                                                  .text
                                                                  .trim();
                                                          String user =
                                                              userController
                                                                  .text
                                                                  .trim();
                                                          String bookingDays =
                                                              bookingDaysController
                                                                  .text
                                                                  .trim();
                                                          String bookedToDate =
                                                              _dateController
                                                                  .text
                                                                  .trim();

                                                          final bookProductDocRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'bookedProducts');

                                                          // Create a new document with post details
                                                          await bookProductDocRef
                                                              .add({
                                                            'userId': userId,
                                                            'productId': widget
                                                                .productId,
                                                            'userName': user,
                                                            'product': product,
                                                            'bookingDays':
                                                                bookingDays,
                                                            'bookedDate': DateTime
                                                                    .now()
                                                                .toLocal()
                                                                .toIso8601String()
                                                                .split('T')[0],
                                                            'bookedToDate':
                                                                bookedToDate,
                                                          });

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Booked successfully')),
                                                          );

                                                          Navigator.pop(
                                                              context);
                                                        } catch (e) {
                                                          print(e);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(e
                                                                    .toString())),
                                                          );
                                                        } finally {
                                                          isLoading = false;
                                                          setDialogState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.r),
                                                            color: Colors
                                                                .blue[900]),
                                                        child: Center(
                                                          child: isLoading
                                                              ? CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : Text(
                                                                  'Book now',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                              },
                              child: Text(
                                isBooked ? 'Already Booked' : 'Book Now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          )
                        ])))));
  }
}
