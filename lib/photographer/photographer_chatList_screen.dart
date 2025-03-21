import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: widget.userId)
            .orderBy('timestamp', descending: true) // Sort by latest message
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }

          var chats = snapshot.data!.docs;

          // Group chats by the other user's ID
          Map<String, QueryDocumentSnapshot> groupedChats = {};
          for (var chat in chats) {
            var participants = chat['participants'] as List<dynamic>;
            var otherUserId = participants.firstWhere(
              (id) => id != widget.userId,
              orElse: () => null,
            );

            if (otherUserId != null) {
              // Keep only the latest chat for each user
              if (!groupedChats.containsKey(otherUserId)) {
                groupedChats[otherUserId] = chat;
              }
            }
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groupedChats.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              var otherUserId = groupedChats.keys.elementAt(index);
              var chat = groupedChats[otherUserId]!;
              var lastMessage = chat['lastMessage'] ?? 'No messages yet';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  var userName = userData?['name'] ?? 'Unknown User';
                  var profileImage = userData?['profileImage'];

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage == null
                          ? Text(
                              userName.isNotEmpty ? userName[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            )
                          : null,
                      backgroundColor: profileImage == null
                          ? Colors.blueAccent
                          : Colors.transparent,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
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
