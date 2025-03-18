import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photohire/user/user_chat_screen.dart';

class UserChatListScreen extends StatefulWidget {
  final String userId;

  const UserChatListScreen({super.key, required this.userId});

  @override
  _UserChatListScreenState createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  TextEditingController _searchController = TextEditingController();

  // Fetch studio details
  Future<Map<String, dynamic>?> _fetchStudioDetails(String studioId) async {
    try {
      DocumentSnapshot studioDoc = await FirebaseFirestore.instance
          .collection('photographers')
          .doc(studioId)
          .get();
      if (studioDoc.exists) {
        return studioDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching studio details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Messages",
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: widget.userId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No Messages Yet!",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            );
          }

          var chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var chatData = chatDocs[index].data() as Map<String, dynamic>;
              String chatId = chatDocs[index].id;
              String studioId = chatData['studioId'];
              String lastMessage = chatData['lastMessage'] ?? "No messages yet";
              Timestamp? lastMessageTime = chatData['lastMessageTime'];
              String formattedTime = lastMessageTime != null
                  ? "${lastMessageTime.toDate().hour}:${lastMessageTime.toDate().minute}"
                  : "";

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchStudioDetails(studioId),
                builder: (context, studioSnapshot) {
                  if (!studioSnapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  var studio = studioSnapshot.data!;
                  String studioName = studio['name'] ?? "Unknown";
                  String companyName = studio['company'] ?? "No Company";
                  String? logoUrl = studio['companyLogo'];

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      backgroundImage:
                          logoUrl != null ? NetworkImage(logoUrl) : null,
                      child: logoUrl == null
                          ? Text(
                              studioName[0].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(studioName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Text(lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    trailing: Text(formattedTime,
                        style: TextStyle(fontSize: 12, color: Colors.black38)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: widget.userId,
                            studioId: studioId,
                            userName: "User",
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
