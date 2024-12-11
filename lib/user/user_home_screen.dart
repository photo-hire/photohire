import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/photographer_details_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> studioData = [];
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      isLoading = true;
      setState(() {});

      // Fetch the documents in the 'photographer' collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('photgrapher').get();

      // Extract data from each document and return as a list of maps
      studioData = snapshot.docs
          .where((doc) => doc.data()['isApproved'] == true)
          .map((doc) => doc.data())
          .toList();
      isLoading = false;
      print('studio data ${studioData.length}');
      setState(() {});
      return studioData;
    } catch (e) {
      isLoading = false;
      setState(() {});
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Location and Profile Icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.purple),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Home",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Kozhikode, Kerala",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundImage: AssetImage(
                          "asset/image/image1.jpg"), // Replace with your profile image asset
                      radius: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'Sign out') {
                        FirebaseAuth.instance.signOut();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'Sign out',
                        child: Text('Sign out'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Search Bar and Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Toggle Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: const Text(
                      "LIST",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid View of Items
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : studioData.length > 0
                    ? Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.7,
                          ),
                          itemCount:
                              studioData.length, // The filtered data count
                          itemBuilder: (context, index) {
                            final photographer = studioData[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PhotographerDetailsScreen(
                                              studioDetails: photographer,
                                            )));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo Section
                                    Container(
                                      height: 100,
                                      width: double.infinity,
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Center(
                                          child: photographer['companyLogo'] ==
                                                  null
                                              ? Text(
                                                  "LOGO HERE",
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                )
                                              : Image.network(
                                                  photographer['companyLogo'],
                                                  fit: BoxFit.fill,
                                                )),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title and Description
                                          Row(
                                            children: [
                                              Text(
                                                photographer['company'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                "4.5",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Icon(Icons.star,
                                                  color: Colors.yellow,
                                                  size: 16),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${photographer['role']} Photographers",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(height: 5),

                                          // Price
                                          Text(
                                            '\$ ${photographer['startingPrice']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text('No data available'),
                      )
          ],
        ),
      ),
      backgroundColor: Colors.purple[50], // Matches the gradient in the image.
    );
  }
}
