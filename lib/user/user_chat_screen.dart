import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  final String studioName;
  final String studioLogo;
  final String studioId;
  final String userId; // Add userId for the current user

  const UserChatScreen({
    super.key,
    required this.studioName,
    required this.studioLogo,
    required this.studioId,
    required this.userId,
  });

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _firestore
          .collection('chats')
          .doc(widget.studioId)
          .collection('messages')
          .add({
        'message': _messageController.text.trim(),
        'sender': widget.userId, // Use userId as the sender
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();

      // Scroll to the bottom after sending a message
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(11),
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white, // White (Bottom)
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Studio Logo and Info
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: widget.studioLogo.isNotEmpty
                        ? NetworkImage(widget.studioLogo)
                        : null,
                    child: widget.studioLogo.isEmpty
                        ? Icon(Icons.camera_alt, size: 30.r)
                        : null,
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    widget.studioName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Chat Messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.studioId)
                    .collection('messages')
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
                        "No messages yet",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index].data() as Map<String, dynamic>;
                      final isUser = message['sender'] == widget.userId;
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Card(
                          color: isUser ? Colors.blue[50] : Colors.white,
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  DateFormat('hh:mm a').format(
                                    (message['timestamp'] as Timestamp).toDate(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Input Field and Send Button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send,
                      size: 28.r,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}