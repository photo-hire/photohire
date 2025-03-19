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
  List<Map<String, dynamic>> _allChats = [];
  List<Map<String, dynamic>> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChats);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch studio details from Firestore
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

  // Fetch last messages for chats the user is part of
  Stream<List<Map<String, dynamic>>> fetchUserChats() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: widget.userId)
        .snapshots()
        .asyncMap((chatSnapshot) async {
      List<Map<String, dynamic>> chatList = [];

      for (var chatDoc in chatSnapshot.docs) {
        String chatId = chatDoc.id;
        String studioId = chatDoc['studioId'] ?? '';

        var messageSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String lastMessage = messageSnapshot.docs.isNotEmpty
            ? messageSnapshot.docs.first['message']
            : "No messages yet";
        Timestamp? lastMessageTime = messageSnapshot.docs.isNotEmpty
            ? messageSnapshot.docs.first['timestamp']
            : null;

        chatList.add({
          'chatId': chatId,
          'studioId': studioId,
          'lastMessage': lastMessage,
          'lastMessageTime': lastMessageTime,
        });
      }

      _allChats = chatList;
      _filteredChats = chatList;
      return chatList;
    });
  }

  // Filter chats based on search input
  void _filterChats() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredChats = _allChats;
      });
      return;
    }

    setState(() {
      _filteredChats = _allChats
          .where((chat) =>
              (chat['studioName'] ?? '').toLowerCase().contains(query) ||
              (chat['lastMessage'] ?? '').toLowerCase().contains(query))
          .toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search messages...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchUserChats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || _filteredChats.isEmpty) {
                  return Center(
                    child: Text("No Messages Yet!",
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredChats.length,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var chatData = _filteredChats[index];
                    String studioId = chatData['studioId'] ?? '';
                    String lastMessage = chatData['lastMessage'];
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
                        String? logoUrl = studio['companyLogo'];

                        chatData['studioName'] = studioName; // Store for search

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors
                                .primaries[index % Colors.primaries.length],
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
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                          trailing: Text(formattedTime,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black38)),
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
          ),
        ],
      ),
    );
  }
}
