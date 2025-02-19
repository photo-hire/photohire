import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_chat_screen.dart';

class StudioChatListScreen extends StatelessWidget {
  final String studioId;

  const StudioChatListScreen({super.key, required this.studioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users Who Messaged You")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('studioChats').doc(studioId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No messages yet"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> users = data['users'] ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              String userId = users[index];

              return ListTile(
                title: Text("User ID: $userId"), // Fetch actual user details if needed
                leading: CircleAvatar(child: Icon(Icons.person)),
                trailing: Icon(Icons.chat),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userId: userId,
                        studioId: studioId,
                        userName: "User Name",
                        studioName: "Studio",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
