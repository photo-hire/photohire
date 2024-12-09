import 'package:flutter/material.dart';

class ExploreScreenWidget extends StatelessWidget {
  final String image;
  final String title;
  final double rating;

  ExploreScreenWidget({
    super.key,
    required this.image,
    required this.rating,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              height: 150, 
              width: double.infinity, 
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
              
                Text(
                  rating.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
