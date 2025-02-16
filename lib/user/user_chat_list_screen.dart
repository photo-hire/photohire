import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'user_chat_screen.dart'; // Import the UserChatScreen

class ChatListingScreen extends StatefulWidget {
  final String userId;

  const ChatListingScreen({super.key, required this.userId});

  @override
  State<ChatListingScreen> createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatMetadata')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue[900],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No chats yet",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            );
          }

          var chats = snapshot.data!.docs;
          print(chats);
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              print(chat);
              return ListTile(
                leading: CircleAvatar(
                  radius: 25.r,
                  backgroundImage: chat['studioLogo'] != null && chat['studioLogo'].isNotEmpty
                      ? NetworkImage(chat['studioLogo'])
                      : null,
                  child: chat['studioLogo'] == null || chat['studioLogo'].isEmpty
                      ? Icon(Icons.camera_alt, size: 25.r)
                      : null,
                ),
                title: Text(
                  chat['studioName'],
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chat['lastMessage'],
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                trailing: Text(
                  DateFormat('hh:mm a').format(
                    (chat['timestamp'] as Timestamp).toDate(),
                  ),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserChatScreen(
                        studioId: chat['studioId'],
                        studioName: chat['studioName'],
                        studioLogo: chat['studioLogo'],
                        userId: widget.userId,
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