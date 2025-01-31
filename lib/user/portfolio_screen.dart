import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';

class ImagePortfolioScreen extends StatefulWidget {
  final List<String> imageUrls; // List of image URLs passed via constructor

  const ImagePortfolioScreen({super.key, required this.imageUrls});

  @override
  State<ImagePortfolioScreen> createState() => _ImagePortfolioScreenState();
}

class _ImagePortfolioScreenState extends State<ImagePortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Portfolio',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 16.w, // Spacing between columns
            mainAxisSpacing: 16.h, // Spacing between rows
            childAspectRatio: 0.8, // Aspect ratio of each grid item
          ),
          itemCount: widget.imageUrls.length,
          itemBuilder:(context, index) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: PhotoView(
              imageProvider: NetworkImage(widget.imageUrls[index]),
            ),
          ),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.network(
         widget.imageUrls[index],
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      ),
    ),
  );
},
        
        ),
      ),
    );
  }
}