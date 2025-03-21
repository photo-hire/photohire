import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class StudioChatScreen extends StatefulWidget {
  final String studioId;
  final String studioName;
  final String studioLogo;
  final String userId;

  const StudioChatScreen({
    super.key,
    required this.studioId,
    required this.studioName,
    required this.studioLogo,
    required this.userId,
  });

  @override
  State<StudioChatScreen> createState() => _StudioChatScreenState();
}

class _StudioChatScreenState extends State<StudioChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        // Add message to Firestore
        await _firestore
            .collection('chats')
            .doc(widget.userId) // Use userId as the document ID
            .collection('messages')
            .add({
          'message': _messageController.text.trim(),
          'sender': widget.studioId, // Sender is the studio
          'timestamp': Timestamp.now(),
        });

        // Update chat metadata
        await _firestore
            .collection('chatMetadata')
            .doc('${widget.userId}_${widget.studioId}')
            .set({
          'userId': widget.userId,
          'studioId': widget.studioId,
          'studioName': widget.studioName,
          'studioLogo': widget.studioLogo,
          'lastMessage': _messageController.text.trim(),
          'timestamp': Timestamp.now(),
        }, SetOptions(merge: true));

        _messageController.clear();

        // Scroll to the bottom after sending a message
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.studioLogo),
              radius: 18.r,
            ),
            SizedBox(width: 10.w),
            Text(
              widget.studioName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.userId) // Use userId as the document ID
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isStudio = message['sender'] == widget.studioId;

                    return Align(
                      alignment: isStudio
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 8.w),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: isStudio ? Colors.blue[900] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isStudio ? 12.r : 0),
                            topRight: Radius.circular(isStudio ? 0 : 12.r),
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isStudio ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('hh:mm a').format(
                                (message['timestamp'] as Timestamp).toDate(),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isStudio
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input Field and Send Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message..',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.r, vertical: 14.h),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[900],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send,
                      size: 24.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
