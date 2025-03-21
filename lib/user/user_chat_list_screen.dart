import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photohire/user/user_chat_screen.dart'; // For date formatting

class UserChatListScreen extends StatefulWidget {
  final String userId;

  const UserChatListScreen({super.key, required this.userId});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    return DateFormat('HH:mm').format(date); // Format as "HH:mm" (e.g., 14:30)
  }

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
            .orderBy('timestamp', descending: true)
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
          Map<String, QueryDocumentSnapshot> groupedChats = {};
          for (var chat in chats) {
            var participants = chat['participants'] as List<dynamic>;
            var otherUserId = participants.firstWhere(
              (id) => id != widget.userId,
              orElse: () => null,
            );

            if (otherUserId != null) {
              if (!groupedChats.containsKey(otherUserId)) {
                groupedChats[otherUserId] = chat;
              }
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: groupedChats.length,
            itemBuilder: (context, index) {
              var otherUserId = groupedChats.keys.elementAt(index);
              var chat = groupedChats[otherUserId]!;
              var lastMessage = chat['lastMessage'] ?? 'No messages yet';
              var lastMessageTimestamp = chat['timestamp'] as Timestamp?;

              return FutureBuilder<DocumentSnapshot>(
                future:
                    _firestore.collection('photgrapher').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  var companyName = userData?['company'] ?? 'Unknown User';
                  var companyLogo = userData?['companyLogo'];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: companyLogo != null
                            ? NetworkImage(companyLogo)
                            : null,
                        child: companyLogo == null
                            ? Text(
                                companyName.isNotEmpty ? companyName[0] : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                        backgroundColor: companyLogo == null
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                      title: Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 18,
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
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (lastMessageTimestamp != null)
                            Text(
                              _formatTimestamp(lastMessageTimestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: otherUserId,
                              senderId: widget.userId,
                              userName: companyName,
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
    );
  }
}
