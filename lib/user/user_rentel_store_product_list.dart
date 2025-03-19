import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/user/user_profile_screen.dart';

class RentalStoreScreen extends StatefulWidget {
  @override
  _RentalStoreScreenState createState() => _RentalStoreScreenState();
}

class _RentalStoreScreenState extends State<RentalStoreScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = "";
  String? _profileImageUrl;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchProducts();
    fetchProfileImage();
  }

  @override
  void dispose() {
    _isMounted = false; // Mark widget as disposed
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('storeProducts').get();

      List<Map<String, dynamic>> fetchedProducts = [];

      for (var doc in querySnapshot.docs) {
        if (doc['productDetails'] is List) {
          for (var product in doc['productDetails']) {
            if (product is Map<String, dynamic>) {
              fetchedProducts.add(product);
            }
          }
        }
      }

      if (_isMounted) {
        setState(() {
          _products = fetchedProducts;
          _filteredProducts = _products;
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> fetchProfileImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists && _isMounted) {
        setState(() {
          _profileImageUrl = userSnapshot['profileImage'];
        });
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products.where((product) {
        final productName = product['name']?.toString().toLowerCase() ?? "";
        return productName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Rental Products",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen()));
              },
              child: CircleAvatar(
                radius: 22,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : AssetImage('asset/image/avatar.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search Products",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(child: Text("No products found"))
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    String productName = product['name'] ?? 'No Name Available';
    String productImage = product['image'] ?? 'https://via.placeholder.com/150';
    String productPrice = product['price']?.toString() ?? '0';

    // Fetch description if available
    String? productDescription = product['description'];

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProductBookingScreen(product: product),
        //   ),
        // );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r), // Rounded corners
        ),
        elevation: 4, // Soft shadow effect
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container (Rounded & Centered)
              Container(
                width: double.infinity,
                height: 100.h, // Adjusted height
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: productImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          productImage,
                          fit: BoxFit.cover, // Cover the container
                        ),
                      )
                    : Center(
                        child: Text(
                          "NO IMAGE",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 8.h),

              // Product Name
              Text(
                productName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 4.h),

              // Price (Left-aligned)
              Text(
                "₹$productPrice",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 4.h),

              // Product Description (Only if available)
              if (productDescription != null && productDescription.isNotEmpty)
                Text(
                  productDescription,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
