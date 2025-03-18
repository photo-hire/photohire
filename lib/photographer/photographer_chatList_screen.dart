import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photohire/user/user_chat_screen.dart';

class StudioChatListScreen extends StatelessWidget {
  final String studioId;

  const StudioChatListScreen({super.key, required this.studioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Messages",
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      )),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('studioChats')
            .doc(studioId)
            .snapshots(),
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

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text("User ID: $userId"),
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      trailing: Icon(Icons.chat),
                    );
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  String userName = userData['name'] ?? "Unknown User";

                  return ListTile(
                    title: Text(userName),
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    trailing: Icon(Icons.chat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: userId,
                            studioId: studioId,
                            userName: userName,
                          ),
                        ),
                      );
                    },
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
