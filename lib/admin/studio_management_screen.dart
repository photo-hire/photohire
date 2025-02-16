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
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text("Studio Management",style: TextStyle(color: Colors.white),),
                  backgroundColor: Colors.black54,
                  elevation: 0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: studios.length,
                    itemBuilder: (context, index) {
                      final studio = studios[index];
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
                                    child: Image.network(
                                      studio["photo"]!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // Studio Name
                                  Expanded(
                                    child: Text(
                                      studio["name"]!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              // Accept and Reject Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      print("${studio['name']} accepted");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: Text("Accept"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      print("${studio['name']} rejected");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text("Reject"),
                                  ),
                                ],
                              ),
                            ],
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


