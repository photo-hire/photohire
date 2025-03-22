import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: photographerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Photographer not found"));
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Section
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: companyLogo.isNotEmpty
                            ? NetworkImage(companyLogo)
                            : const AssetImage('asset/image/avatar.png')
                                as ImageProvider,
                      ),
                      SizedBox(height: 10.h),
                      Text(studioName,
                          style: GoogleFonts.poppins(
                              fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      Text("${data["role"]} at $studioName",
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp, color: Colors.grey)),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Information Cards
                  _buildInfoCard("📖 About", description),
                  _buildInfoCard("📧 Contact", "📞 $phone\n✉️ $email"),
                  _buildInfoCard("💰 Starting Price", "₹$startingPrice"),

                  // Location Section
                  _buildLocationCard(location),

                  // Portfolio Section
                  _buildPortfolioSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 5.h),
          Text(content,
              style:
                  GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LatLng location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📍 Location",
            style: GoogleFonts.poppins(
                fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: 180.h,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: location, zoom: 14),
              markers: {
                Marker(
                    markerId: const MarkerId("photographerLocation"),
                    position: location)
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📸 Portfolio",
            style: GoogleFonts.poppins(
                fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 10.h),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.photographerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                  child: Text('No portfolio images found',
                      style: GoogleFonts.poppins(color: Colors.black54)));
            }
            List<Map<String, dynamic>> portfolio =
                List<Map<String, dynamic>>.from(
                    snapshot.data!['postDetails'] ?? []);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h),
              itemCount: portfolio.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
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
