import 'package:flutter/material.dart';
import 'package:photohire/customwidgets/payment_method_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'paypal'; // Initial selected payment method

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payment'),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(10, 10),
                        blurRadius: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 30,
                        color: Colors.blue,
                      ),
                      Text('Add Credit or Debit Card'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                PaymentMethodWidget(
                  value: 'paypal',
                  groupValue: selectedPaymentMethod,
                  image: 'asset/image/paypal-removebg-preview.png',
                  title: 'Paypal',
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                PaymentMethodWidget(
                  value: 'googlepay',
                  groupValue: selectedPaymentMethod,
                  image: 'asset/image/6124998.png',
                  title: 'Google Pay',
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                PaymentMethodWidget(
                  value: 'applepay',
                  groupValue: selectedPaymentMethod,
                  image: 'asset/image/Apple_Pay-Logo.wine.png',
                  title: 'ApplePay',
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                ),
                SizedBox(height: 140,),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('Continue',style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
