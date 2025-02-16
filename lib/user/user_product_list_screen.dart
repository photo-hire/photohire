import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photohire/user/user_product_details_screen.dart';


class ParentWidget extends StatelessWidget {
  final Map<String, dynamic> store;

  const ParentWidget({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(store);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchProductDetails(store['id']),
      builder: (context, snapshot) {
        print(store['id']);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(body: Center(child: Text('No products found.')));
        } else {
          print('ppppppppp');
          print(snapshot.data);
          return UserRentalServiceScreen(
            store: store['data'],
            productDetails: snapshot.data!,
          );
        }
      },
    );
  }
}



Future<List<Map<String, dynamic>>> fetchProductDetails(String storeId) async {
  print('hi');
  List<Map<String, dynamic>> productDetails = [];
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('storeProducts')
      .where('userId', isEqualTo: storeId)
      .get();

  for (var doc in querySnapshot.docs) {
    productDetails.add(doc.data() as Map<String, dynamic>);
  }

  return productDetails;
}





class UserRentalServiceScreen extends StatelessWidget {
  final Map<String, dynamic> store;
  final List<Map<String, dynamic>> productDetails;

  const UserRentalServiceScreen({
    Key? key,
    required this.store,
    required this.productDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Store Logo and Gradient Background
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Store Logo
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: store['companyLogo']??'',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pinned: true,
            elevation: 10,
          ),
          // Store Details and Products
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    store['storeName']??'',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Store Description
                  Text(
                    store['description']??'',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Contact Info Section
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Email
                          ListTile(
                            leading: Icon(Icons.email, color: Colors.blueAccent),
                            title: Text(
                              store['email']??'',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          Divider(),
                          // Phone
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.green),
                            title: Text(
                              store['phone']??'',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Products Section
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Product List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: productDetails.length,
                    itemBuilder: (context, index) {
                      final product = productDetails[index];
                      return ProductItem(product: product);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('------------------');
    print(product);
    return GestureDetector(
      onTap:  () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProductDetailsScreen(product: product['productDetails'][0])));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product['productDetails'][0]['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 10),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['productDetails'][0]['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      product['productDetails'][0]['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Price: \$${product['productDetails'][0]['price']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}