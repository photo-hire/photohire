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
  String _searchQuery = '';

  Future<Map<String, dynamic>?> _fetchStudioDetails(String studioId) async {
    DocumentSnapshot studioDoc = await FirebaseFirestore.instance
        .collection('photographers')
        .doc(studioId)
        .get();
    if (studioDoc.exists) {
      return studioDoc.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message",
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              showSearch(
                context: context,
                delegate:
                    ChatSearchDelegate(widget.userId, _fetchStudioDetails),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userChats')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text("No Messages Yet!",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> studios = data['studios'] ?? [];

          return ListView.builder(
            itemCount: studios.length,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              String studioId = studios[index];

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
                    subtitle: Text(companyName,
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    trailing: Text("12:19",
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

// Search Delegate for Chat List
class ChatSearchDelegate extends SearchDelegate {
  final String userId;
  final Future<Map<String, dynamic>?> Function(String) fetchStudioDetails;

  ChatSearchDelegate(this.userId, this.fetchStudioDetails);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildChatList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildChatList();
  }

  Widget _buildChatList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userChats')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text("No Messages Found!",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> studios = data['studios'] ?? [];

        return ListView.builder(
          itemCount: studios.length,
          itemBuilder: (context, index) {
            String studioId = studios[index];

            return FutureBuilder<Map<String, dynamic>?>(
              future: fetchStudioDetails(studioId),
              builder: (context, studioSnapshot) {
                if (!studioSnapshot.hasData) {
                  return SizedBox.shrink();
                }

                var studio = studioSnapshot.data!;
                String studioName = studio['name'] ?? "Unknown";
                String companyName = studio['company'] ?? "No Company";
                String? logoUrl = studio['companyLogo'];

                if (!studioName.toLowerCase().contains(query.toLowerCase())) {
                  return SizedBox.shrink();
                }

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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: Text(companyName,
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  trailing: Text("12:19",
                      style: TextStyle(fontSize: 12, color: Colors.black38)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userId: userId,
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
    );
  }
}
