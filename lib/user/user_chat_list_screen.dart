import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_chat_screen.dart';

class UserChatListScreen extends StatelessWidget {
  final String userId;

  const UserChatListScreen({super.key, required this.userId});

  Future<Map<String, dynamic>?> _fetchStudioDetails(String studioId) async {
    DocumentSnapshot studioDoc = await FirebaseFirestore.instance.collection('photgrapher').doc(studioId).get();
    if (studioDoc.exists) {
      return studioDoc.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Studios You've Messaged"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
     
      body: Container(
        padding: EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white, // White (Bottom)
            ],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('userChats').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  "No messages yet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              );
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> studios = data['studios'] ?? [];

            return ListView.builder(
              itemCount: studios.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                String studioId = studios[index];

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchStudioDetails(studioId),
                  builder: (context, studioSnapshot) {
                    if (!studioSnapshot.hasData) {
                      return ListTile(
                        title: Text("Loading...", style: TextStyle(color: Colors.white)),
                        leading: CircleAvatar(child: Icon(Icons.business, color: Colors.white)),
                      );
                    }

                    var studio = studioSnapshot.data!;
                    String studioName = studio['name'] ?? "Unknown";
                    String companyName = studio['company'] ?? "No Company";
                    String startingPrice = studio['startingPrice'] ?? "N/A";
                    String? logoUrl = studio['companyLogo'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                          child: logoUrl == null ? Icon(Icons.business, color: Colors.blueAccent) : null,
                        ),
                        title: Text(studioName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text("$companyName • Starting from ₹$startingPrice", style: TextStyle(fontSize: 14)),
                        trailing: Icon(Icons.chat, color: Colors.blueAccent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userId: userId,
                                studioId: studioId,
                                userName: "User", // Fetch actual user name if needed
                                studioName: studioName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
