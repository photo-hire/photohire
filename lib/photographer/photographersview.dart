import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'photographer_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Stream<DocumentSnapshot<Object?>>? getStudioStream() {
    if (currentUserId.isNotEmpty) {
      return photographers.doc(currentUserId).snapshots();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent bottom overflow
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: getStudioStream(),
          builder: (context, snapshot) {
            String studioName = "Studio";
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              studioName = data['company'] ?? "Studio";
            }
            return Text(
              "Welcome, $studioName",
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: StreamBuilder<DocumentSnapshot>(
              stream: getStudioStream(),
              builder: (context, snapshot) {
                String companyLogoUrl = "";
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  companyLogoUrl = data['companyLogo'] ?? "";
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhotographerProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: companyLogoUrl.isNotEmpty
                        ? NetworkImage(companyLogoUrl)
                        : null,
                    child: companyLogoUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for photographers...',
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                  hintStyle: TextStyle(color: Colors.grey),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No Posts Found'));
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>?;
                    var studioId = data?['userId'] ?? "";
                    return studioId != currentUserId;
                  }).toList();

                  return GridView.builder(
                    padding: EdgeInsets.all(10.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredDocs.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var post =
                          filteredDocs[index].data() as Map<String, dynamic>?;

                      if (post == null) return SizedBox.shrink();

                      var imageUrl = post['imageUrl'] ?? '';
                      var studioId = post['userId'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: photographers.doc(studioId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox();
                          }
                          if (!snapshot.hasData ||
                              !(snapshot.data?.exists ?? false)) {
                            return SizedBox.shrink();
                          }

                          var studioData =
                              snapshot.data!.data() as Map<String, dynamic>?;

                          if (studioData == null) return SizedBox.shrink();

                          var studioName = studioData['company'] ?? "Studio";

                          if (searchQuery.isNotEmpty &&
                              !studioName.toLowerCase().contains(searchQuery)) {
                            return SizedBox.shrink();
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoDetailScreen(imageUrl: imageUrl),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: double.infinity,
                                    height: 100.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  studioName,
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
      ),
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final String imageUrl;

  PhotoDetailScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              Icon(Icons.error, size: 50, color: Colors.red),
        ),
      ),
    );
  }
}
