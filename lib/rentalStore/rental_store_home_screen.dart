import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RentalStoreHomeScreen extends StatefulWidget {
  const RentalStoreHomeScreen({super.key});

  @override
  State<RentalStoreHomeScreen> createState() => _RentalStoreHomeScreenState();
}

class _RentalStoreHomeScreenState extends State<RentalStoreHomeScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // ✅ FIXED Delete Product Function
  Future<void> deleteProduct(String productId) async {
    try {
      final storeProductsCollection =
          FirebaseFirestore.instance.collection('storeProducts');

      FirebaseFirestore.instance
          .collection('storeProducts')
          .doc(productId)
          .delete();

      // Get the correct document for the logged-in user
      final querySnapshot = await storeProductsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        List<dynamic> productDetails = List.from(doc['productDetails'] ?? []);

        // Remove product with matching ID
        productDetails.removeWhere((product) => product['id'] == productId);

        // Update Firestore
        await storeProductsCollection
            .doc(doc.id)
            .update({'productDetails': productDetails});
      }

      print('✅ Product deleted successfully');
      setState(() {}); // Refresh UI
    } catch (e) {
      print('❌ Error deleting product: $e');
    }
  }

  // ✅ Edit Product Function
  Future<void> editProduct(Map<String, dynamic> product) async {
    TextEditingController nameController =
        TextEditingController(text: product['name'] ?? 'Unknown');
    TextEditingController priceController =
        TextEditingController(text: (product['price'] ?? 0).toString());

    File? newImageFile;
    String newImageUrl = product['image'] ?? '';

    // Future<void> pickImage() async {
    //   final pickedFile =
    //       await ImagePicker().pickImage(source: ImageSource.gallery);
    //   if (pickedFile != null) {
    //     setState(() {
    //       newImageFile = File(pickedFile.path);
    //     });

    //     try {
    //       String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    //       Reference ref =
    //           FirebaseStorage.instance.ref().child("product_images/$fileName");
    //       UploadTask uploadTask = ref.putFile(newImageFile!);
    //       TaskSnapshot taskSnapshot = await uploadTask;
    //       newImageUrl = await taskSnapshot.ref.getDownloadURL();
    //     } catch (e) {
    //       print("❌ Error uploading image: $e");
    //     }
    //   }
    // }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Price"),
            ),
            SizedBox(height: 10),
            newImageFile == null
                ? (newImageUrl.isNotEmpty
                    ? Image.network(newImageUrl, height: 100)
                    : Container(height: 100, color: Colors.grey[300]))
                : Image.file(newImageFile!, height: 100),
            ElevatedButton(
              onPressed: () {},
              child: Text("Upload New Image"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final storeProductsCollection =
                    FirebaseFirestore.instance.collection('storeProducts');
                final querySnapshot = await storeProductsCollection
                    .where('userId', isEqualTo: userId)
                    .get();

                for (var doc in querySnapshot.docs) {
                  List<dynamic> productDetails =
                      List.from(doc['productDetails'] ?? []);
                  int index = productDetails
                      .indexWhere((p) => p['id'] == product['id']);

                  if (index != -1) {
                    productDetails[index] = {
                      'docId': doc.id,
                      'id': product['id'],
                      'name': nameController.text,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'image': newImageUrl,
                    };

                    await storeProductsCollection
                        .doc(product['docId'])
                        .update({'productDetails': productDetails});
                  }
                }

                setState(() {});
                Navigator.pop(context);
              } catch (e) {
                print('❌ Error updating product: $e');
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // ✅ Show Options Dialog
  void showOptionsDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Options"),
        content: Text("What do you want to do?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              editProduct(product);
            },
            child: Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              print(product);
              deleteProduct(product['docId']);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
              Center(
                child: Text(
                  "My Dashboard",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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

                        final storeProducts = snapshot.data!.docs.where((doc) {
                          return doc.data()['userId'] == userId;
                        }).toList();

                        final List<Map<String, dynamic>> productDetails =
                            storeProducts.expand((doc) {
                          return List<Map<String, dynamic>>.from(
                              doc.data()['productDetails'] ?? []);
                        }).toList();

                        return productDetails.isEmpty
                            ? const Center(
                                child: Text('No products to display'))
                            : GridView.builder(
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
                                  return GestureDetector(
                                    onTap: () => showOptionsDialog(product),
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.network(
                                              product['image'] ?? '',
                                              height: 150.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Text(product['name'] ?? 'Unknown'),
                                          Text('₹${product['price'] ?? 0}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                      })),
            ],
          ),
        ),
      ),
    ));
  }
}
