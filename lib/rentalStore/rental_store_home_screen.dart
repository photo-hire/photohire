import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RentalStoreHomeScreen extends StatefulWidget {
  const RentalStoreHomeScreen({super.key});

  @override
  State<RentalStoreHomeScreen> createState() => _RentalStoreHomeScreenState();
}

class _RentalStoreHomeScreenState extends State<RentalStoreHomeScreen> {
  TextEditingController searchController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('storeProducts')
          .doc(userId)
          .update({
        'productDetails': FieldValue.arrayRemove([
          {'id': productId}
        ])
      });
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(11),
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249),
              Color.fromARGB(255, 162, 213, 255),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey)),
              ),
              SizedBox(height: 20.h),
              Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('storeProducts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No products found'));
                        }

                        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                            storeProducts = snapshot.data!.docs.where((doc) {
                          return doc.data()['userId'] == userId;
                        }).toList();

                        final List<Map<String, dynamic>> productDetails =
                            storeProducts.expand((doc) {
                          return List<Map<String, dynamic>>.from(
                              doc.data()['productDetails'] ?? []);
                        }).toList();

                        return productDetails.isEmpty
                            ? const Center(child: Text('No products to display'))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: productDetails.length,
                                  itemBuilder: (context, index) {
                                    final product = productDetails[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.r)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10.r),
                                                    topRight:
                                                        Radius.circular(10.r)),
                                                child: Image.network(
                                                  product['image'],
                                                  fit: BoxFit.cover,
                                                  height: 150.h,
                                                  width: double.infinity,
                                                ),
                                              ),
                                              Positioned(
                                                right: 5,
                                                top: 5,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    deleteProduct(product['id']);
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'],
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '\$${product['price']}',
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                      }))
            ],
          ),
        ),
      ),
    ));
  }
}
