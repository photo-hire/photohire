import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudioManagementScreen extends StatefulWidget {
  @override
  _StudioManagementScreenState createState() => _StudioManagementScreenState();
}

class _StudioManagementScreenState extends State<StudioManagementScreen> with SingleTickerProviderStateMixin {
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

  Future<void> _deleteStudio(String docId) async {
    await _firestore.collection('photgrapher').doc(docId).delete();
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
                    _buildStudioList(false),
                    _buildStudioList(true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudioList(bool isApproved) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('photgrapher').where('isApproved', isEqualTo: isApproved).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No studios found'));
        }

        final studios = snapshot.data!.docs;

        return ListView.builder(
          itemCount: studios.length,
          itemBuilder: (context, index) {
            final studio = studios[index].data() as Map<String, dynamic>;
            final docId = studios[index].id;

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
                        // Studio Photo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: studio['companyLogo'] != null
                              ? Image.network(
                                  studio['companyLogo'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.business, size: 80),
                        ),
                        SizedBox(width: 10),
                        // Studio Name
                        Expanded(
                          child: Text(
                            studio['name'] ?? 'No Name',
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
                    Text(studio['Description'] ?? 'No Description'),
                    SizedBox(height: 10),
                    // Document Link
                    TextButton.icon(
                      onPressed: () {
                        print("View document: ${studio['document']}");
                      },
                      icon: Icon(Icons.description),
                      label: Text("View Document"),
                    ),
                    SizedBox(height: 10),
                    // Buttons for Pending and Accepted Studios
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
                          // Delete Button for Pending Studios
                          ElevatedButton(
                            onPressed: () {
                              _deleteStudio(docId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    if (isApproved)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteStudio(docId);
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