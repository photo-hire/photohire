import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/user/user_product_details_screen.dart';
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
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    fetchProducts();
    fetchProfileImage();
  }

  @override
  void dispose() {
    _isMounted = false;
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
              fetchedProducts.add({
                ...product,
                'id': doc.id,
              });
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
      if (_currentUserId == null) return;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

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
        title: Text(
          "Rental Products",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen()));
              },
              child: CircleAvatar(
                radius: 22.r,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search Products",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
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
    return GestureDetector(
      onTap: () {
        if (_currentUserId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProductDetailsScreen(
                productId: product['id'] ?? '',
                name: product['name'] ?? 'No Name Available',
                image: product['image'] ?? 'https://via.placeholder.com/150',
                desc: product['description'] ?? "No description available",
                price: product['price']?.toString() ?? '0',
                userId: _currentUserId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not logged in")),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        elevation: 3,
        shadowColor: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                child: CachedNetworkImage(
                  imageUrl:
                      product['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'No Name Available',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "₹${product['price']}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
