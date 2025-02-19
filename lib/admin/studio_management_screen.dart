import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudioManagementScreen extends StatefulWidget {
  @override
  _StudioManagementScreenState createState() => _StudioManagementScreenState();
}

class _StudioManagementScreenState extends State<StudioManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateApprovalStatus(String docId, bool isApproved) async {
    await _firestore.collection('photgrapher').doc(docId).update({
      'isApproved': isApproved,
    });
  }

  Future<void> _deleteStore(String docId) async {
    await _firestore.collection('photgrapher').doc(docId).delete();
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Studio Management", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            "asset/image/frontscreen.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoreList(false),
                    _buildStoreList(true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(bool isApproved) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('photgrapher')
          .where('isApproved', isEqualTo: isApproved)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No photographers found'));
        }

        final stores = snapshot.data!.docs;

        return ListView.builder(
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index].data() as Map<String, dynamic>;
            final docId = stores[index].id;

            return Card(
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Store Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: store['companyLogo'] != null
                              ? Image.network(
                                  store['companyLogo'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.store, size: 80),
                        ),
                        SizedBox(width: 10),
                        // Store Name
                        Expanded(
                          child: Text(
                            store['storeName'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Description
                    Text(store['description'] ?? 'No Description'),
                    SizedBox(height: 10),
                    // Email
                    Text("Email: ${store['email'] ?? 'No Email'}"),
                    SizedBox(height: 10),
                    // Phone
                    Text("Phone: ${store['phone'] ?? 'No Phone'}"),
                    SizedBox(height: 10),
                    // Location (Latitude and Longitude)
                    Text(
                        "Location: (${store['latitude']}, ${store['longitude']})"),
                    SizedBox(height: 10),
                    // Button to View Location on Google Maps
                    ElevatedButton.icon(
                      onPressed: () {
                        final double latitude = store['latitude'];
                        final double longitude = store['longitude'];
                        _openMap(latitude, longitude);
                      },
                      icon: Icon(Icons.map),
                      label: Text("View on Map"),
                    ),
                    SizedBox(height: 10),
                    // Buttons for Pending and Accepted Stores
                    if (!isApproved)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _updateApprovalStatus(docId, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text("Accept"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _updateApprovalStatus(docId, false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text("Reject"),
                          ),
                        ],
                      ),

                    // Delete Button (Only for Accepted Studios)
                    if (isApproved)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteStore(docId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text("Delete"),
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
  }
}
