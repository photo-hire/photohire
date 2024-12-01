import 'package:flutter/material.dart';

class StudioManagementScreen extends StatelessWidget {
  final List<Map<String, String>> studios = [
    {
      "name": "Studio A",
      "photo": "https://via.placeholder.com/150",
      "document": "https://example.com/doc1.pdf"
    },
    {
      "name": "Studio B",
      "photo": "https://via.placeholder.com/150",
      "document": "https://example.com/doc2.pdf"
    },
    {
      "name": "Studio C",
      "photo": "https://via.placeholder.com/150",
      "document": "https://example.com/doc3.pdf"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        ),
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


