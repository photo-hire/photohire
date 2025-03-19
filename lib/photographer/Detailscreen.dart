import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailsScreen extends StatefulWidget {
  final String photographerId;
  final String? studioName;
  final String? companyLogo;
  final String? startingPrice;
  final String? email;
  final String? phone;
  final String? description;

  const DetailsScreen({
    super.key,
    required this.photographerId,
    this.studioName,
    this.companyLogo,
    this.startingPrice,
    this.email,
    this.phone,
    this.description,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<DocumentSnapshot> photographerFuture;

  @override
  void initState() {
    super.initState();
    photographerFuture = FirebaseFirestore.instance
        .collection('photgrapher')
        .doc(widget.photographerId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studioName ?? "Photographer Details",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: photographerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return Center(child: Text("Photographer not found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String studioName = widget.studioName ?? data["company"] ?? "Studio";
          String companyLogo = widget.companyLogo ?? data["companyLogo"] ?? "";
          String startingPrice = widget.startingPrice ??
              data["startingPrice"]?.toString() ??
              "Not Available";
          String email = widget.email ?? data["email"] ?? "No Email";
          String phone = widget.phone ?? data["phone"] ?? "No Phone";
          String description =
              widget.description ?? data["description"] ?? "No Description";
          LatLng location = LatLng(data["latitude"], data["longitude"]);

          return SingleChildScrollView(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 55.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: companyLogo.isNotEmpty
                        ? NetworkImage(companyLogo)
                        : AssetImage('asset/image/avatar.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 15.h),
                Center(
                  child: Text(studioName,
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 5.h),
                Center(
                  child: Text("${data["role"]} at $studioName",
                      style:
                          TextStyle(fontSize: 16.sp, color: Colors.grey[700])),
                ),
                SizedBox(height: 15.h),
                _buildInfoCard("About", description),
                _buildInfoCard("Contact", "📧 $email\n📞 $phone"),
                _buildInfoCard("Starting Price", "₹$startingPrice"),
                _buildLocationCard(location),
                _buildPortfolioSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 5.h),
            Text(content, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(LatLng location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 5.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: location, zoom: 14),
              markers: {
                Marker(
                  markerId: MarkerId("photographerLocation"),
                  position: location,
                ),
              },
            ),
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Portfolio",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.photographerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No portfolio images found'));
            }
            List<Map<String, dynamic>> portfolio =
                List<Map<String, dynamic>>.from(
                    snapshot.data!['postDetails'] ?? []);
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1,
              ),
              itemCount: portfolio.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(portfolio[index]['image'],
                      fit: BoxFit.cover),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
