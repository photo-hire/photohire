import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExploreScreenWidget extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final double rating;

  ExploreScreenWidget({
    super.key,
    required this.image,
    required this.rating,
    required this.price,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              height: 120.h,
              width: double.infinity,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, top: 10, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\₹$price',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '$rating',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 17.sp,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
