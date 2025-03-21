import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/photographer/Detailscreen.dart';
import 'package:photohire/photographer/photographer_profile_screen.dart';

class PhotographerScreen extends StatefulWidget {
  @override
  _PhotographerScreenState createState() => _PhotographerScreenState();
}

class _PhotographerScreenState extends State<PhotographerScreen> {
  final CollectionReference photographers =
      FirebaseFirestore.instance.collection('photgrapher');
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');
  final FirebaseAuth auth = FirebaseAuth.instance;

  String searchQuery = "";
  TextEditingController searchController = TextEditingController();
  String currentUserId = "";
  String profileImageUrl = "";
  String studioName = "Studio";

  @override
  void initState() {
    super.initState();
    User? user = auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      fetchProfileImageAndName();
    }
  }

  void fetchProfileImageAndName() async {
    DocumentSnapshot photographerDoc =
        await photographers.doc(currentUserId).get();
    if (photographerDoc.exists) {
      setState(() {
        profileImageUrl = photographerDoc.get('companyLogo') ?? "";
        studioName = photographerDoc.get('company') ?? "Studio";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Welcome\n",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp, // Adjust size for the first line
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: studioName,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 22.sp, // Adjust size for the second line
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotographerProfileScreen(),
                ),
              ),
              child: CircleAvatar(
                radius: 20.r,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : AssetImage('asset/image/avatar.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by studio name...',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: posts.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<Map<String, dynamic>> imageList = [];

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  var studioId = data['userId'] ?? "";
                  if (studioId == currentUserId) continue;

                  var images = (data['postDetails'] as List?) ?? [];
                  for (var imageDoc in images) {
                    if (imageDoc is Map<String, dynamic> &&
                        imageDoc.containsKey('image')) {
                      imageList.add({
                        'imageUrl': imageDoc['image'],
                        'studioId': studioId
                      });
                    }
                  }
                }

                imageList.shuffle(Random()); // Shuffle images

                imageList.sort((a, b) {
                  var aStudioId = a['studioId'];
                  var bStudioId = b['studioId'];
                  bool aMatches = aStudioId.toLowerCase().contains(searchQuery);
                  bool bMatches = bStudioId.toLowerCase().contains(searchQuery);
                  return aMatches == bMatches ? 0 : (aMatches ? -1 : 1);
                });

                return GridView.builder(
                  padding: EdgeInsets.all(10.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    var imageData = imageList[index];
                    var imageUrl = imageData['imageUrl'];
                    var studioId = imageData['studioId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: photographers.doc(studioId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            !(snapshot.data?.exists ?? false)) {
                          return SizedBox.shrink();
                        }

                        var studioData =
                            snapshot.data!.data() as Map<String, dynamic>?;

                        var studioName = studioData?['company'] ?? "Studio";

                        if (searchQuery.isNotEmpty &&
                            !studioName.toLowerCase().contains(searchQuery)) {
                          return SizedBox.shrink();
                        }

                        return GestureDetector(
                          onTap: () {
                            if (studioData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    photographerId: studioId,
                                    studioName:
                                        studioData['company'] ?? "Studio",
                                    companyLogo:
                                        studioData['companyLogo'] ?? "",
                                    startingPrice:
                                        studioData['startingPrice'] ??
                                            "Not Available",
                                    email: studioData['email'] ?? "No Email",
                                    phone: studioData['phone'] ?? "No Phone",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Studio details not available')),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                Positioned(
                                  bottom: 8.h,
                                  left: 8.w,
                                  child: Text(
                                    studioName,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      // backgroundColor:
                                      //     Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
