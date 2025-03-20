import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_chat_screen.dart';

class UserChatListScreen extends StatefulWidget {
  final String userId;

  const UserChatListScreen({super.key, required this.userId});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs;

          // Group chats by the other user's ID
          Map<String, List<QueryDocumentSnapshot>> groupedChats = {};
          for (var chat in chats) {
            var participants = chat['participants'] as List<dynamic>;
            var otherUserId = participants.firstWhere(
              (id) => id != widget.userId,
              orElse: () => null,
            );

            if (otherUserId != null) {
              if (!groupedChats.containsKey(otherUserId)) {
                groupedChats[otherUserId] = [];
              }
              groupedChats[otherUserId]!.add(chat);
            }
          }

          // Display each user with their latest chat
          return ListView.builder(
            itemCount: groupedChats.length,
            itemBuilder: (context, index) {
              var otherUserId = groupedChats.keys.elementAt(index);
              var userChats = groupedChats[otherUserId]!;

              // Get the latest chat for this user
              var latestChat = userChats.last;
              var lastMessage = latestChat['lastMessage'] ?? 'No messages yet';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('photgrapher').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  var userName = userData?['company'] ?? 'Unknown User';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(userName),
                    subtitle: Text(
                      lastMessage,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: otherUserId,
                            senderId: widget.userId,
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