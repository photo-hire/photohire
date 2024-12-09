import 'package:flutter/material.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String image;
  final String value;
  final String groupValue;
  final String title;
  final ValueChanged<String> onChanged; // Callback to notify parent

  PaymentMethodWidget({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.image,
    required this.title,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
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
      child: Row(
        children: [
          Radio(
            activeColor: Colors.blue[900],
            value: value,
            groupValue: groupValue,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Image.asset(image, height: 50),
        ],
      ),
    );
  }
}
