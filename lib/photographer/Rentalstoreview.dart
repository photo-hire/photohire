import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_booking_screen.dart'; // Import the correct screen
import 'photographer_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String profileImageUrl = "";

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  void fetchProfileImage() async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot photographerDoc = await FirebaseFirestore.instance
          .collection('photgrapher')
          .doc(user.uid)
          .get();

      if (photographerDoc.exists && photographerDoc['companyLogo'] != null) {
        setState(() {
          profileImageUrl = photographerDoc['companyLogo'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rental Products',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotographerProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage('asset/image/avatar.png')
                              as ImageProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    hintText: 'Search Products',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('storeProducts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }

                    var products = snapshot.data!.docs.where((doc) {
                      var name = (doc['productDetails'][0]['name'] as String)
                          .toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index]['productDetails'][0];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductBookingScreen(
                                  productName: product['name'],
                                  image: product['image'],
                                  desc: product['description'],
                                  // rating: product['rating']?.toDouble() ?? 0.0,
                                  price: product['price'].toString(),
                                  productId: products[index].id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      product['image'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      Text(
                                        "₹${product['price']}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product['description'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
