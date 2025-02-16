import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photohire/user/user_product_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RentalStoreScreen extends StatelessWidget {
  // Fetch data from Firestore
  Future<List<Map<String, dynamic>>> fetchRentalStores() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rentalStore')
          .where('isApproved', isEqualTo: true) // Only fetch approved stores
          .get();

      return querySnapshot.docs.map((doc) => {'data':doc.data(), 'id': doc.id }as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching rental stores: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Stores'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRentalStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading rental stores'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No rental stores found'));
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.5, // Adjust the aspect ratio for card size
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final store = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParentWidget(store: store),
                      ),
                    );
                  },
                  child: RentalStoreCard(store: store['data']));
              },
            );
          }
        },
      ),
    );
  }
}



class RentalStoreCard extends StatelessWidget {
  final Map<String, dynamic> store;

  const RentalStoreCard({Key? key, required this.store}) : super(key: key);

  // Function to open Google Maps
  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Logo
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: store['companyLogo'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Name
                Text(
                  store['storeName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Store Description
                
               
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        store['email'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Store Phone
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      store['phone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Map Icon to Open Google Maps
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.map, color: Colors.red),
                    onPressed: () {
                      _openGoogleMaps(
                        store['latitude'],
                        store['longitude'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




