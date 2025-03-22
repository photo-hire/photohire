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
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> deleteProduct(String productId) async {
    try {
      final storeProductsCollection =
          FirebaseFirestore.instance.collection('storeProducts');
      final querySnapshot = await storeProductsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        List<dynamic> productDetails = List.from(doc['productDetails'] ?? []);
        productDetails.removeWhere((product) => product['id'] == productId);

        await storeProductsCollection
            .doc(doc.id)
            .update({'productDetails': productDetails});
      }
      setState(() {});
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> editProduct(
      String productId, String name, String description, String price) async {
    try {
      final storeProductsCollection =
          FirebaseFirestore.instance.collection('storeProducts');
      final querySnapshot = await storeProductsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        List<dynamic> productDetails = List.from(doc['productDetails'] ?? []);
        for (var product in productDetails) {
          if (product['id'] == productId) {
            product['name'] = name;
            product['description'] = description;
            product['price'] = price;
          }
        }

        await storeProductsCollection
            .doc(doc.id)
            .update({'productDetails': productDetails});
      }
      setState(() {});
    } catch (e) {
      print('Error editing product: $e');
    }
  }

  void showOptionsDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Product Options"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showEditDialog(context, product);
              },
              child: Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                if (product['id'] != null) {
                  deleteProduct(product['id'].toString());
                }
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> product) {
    TextEditingController nameController =
        TextEditingController(text: product['name']?.toString() ?? '');
    TextEditingController descController =
        TextEditingController(text: product['description']?.toString() ?? '');
    TextEditingController priceController =
        TextEditingController(text: product['price']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Product Name"),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                editProduct(
                    product['id']?.toString() ?? '',
                    nameController.text,
                    descController.text,
                    priceController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "My Dashboard",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('storeProducts')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No products found'));
              }

              final storeProducts = snapshot.data!.docs
                  .where((doc) => doc.data()['userId'] == userId)
                  .toList();
              final List<Map<String, dynamic>> productDetails =
                  storeProducts.expand((doc) {
                return List<Map<String, dynamic>>.from(
                    doc.data()['productDetails'] ?? []);
              }).toList();

              return productDetails.isEmpty
                  ? Center(child: Text('No products to display'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: productDetails.length,
                      itemBuilder: (context, index) {
                        final product = productDetails[index];
                        return GestureDetector(
                          onTap: () => showOptionsDialog(context, product),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['image'] ?? '',
                                      height: 120.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    product['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    product['description'] ?? 'No description',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Spacer(),
                                  Text(
                                    '₹${product['price'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
        ),
      ),
    );
  }
}
