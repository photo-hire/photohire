import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:photohire/photographer/photo_chat_screen.dart';

class StudioUserListScreen extends StatefulWidget {
  final String studioId;

  const StudioUserListScreen({super.key, required this.studioId});

  @override
  State<StudioUserListScreen> createState() => _StudioUserListScreenState();
}

class _StudioUserListScreenState extends State<StudioUserListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users', style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatMetadata')
            .where('studioId', isEqualTo: widget.studioId)
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
                "No users yet",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            );
          }

          var chats = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final String userId = chat['userId'];

              // Fetch user details from the 'users' collection
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.r,
                        child: Icon(Icons.person, size: 25.r),
                      ),
                      title: Text(
                        'Loading...',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.r,
                        child: Icon(Icons.person, size: 25.r),
                      ),
                      title: Text(
                        'Unknown User',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final String userName = userData['name'] ?? 'Unknown User';
                  final String userProfileImage = userData['profileImage'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25.r,
                      backgroundImage: userProfileImage.isNotEmpty
                          ? NetworkImage(userProfileImage)
                          : null,
                      child: userProfileImage.isEmpty
                          ? Icon(Icons.person, size: 25.r)
                          : null,
                    ),
                    title: Text(
                      userName,
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
      builder: (context) => StudioChatScreen(
        studioId: widget.studioId,
        studioName: chat['studioName'],
        studioLogo: chat['studioLogo'],
        userId: chat['userId'],
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