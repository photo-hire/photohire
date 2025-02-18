import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String studioId;
  final String userName;
  final String studioName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.studioId,
    required this.userName,
    required this.studioName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get chatId => '${widget.userId}_${widget.studioId}';

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'message': message,
      'senderId': widget.userId,
      'receiverId': widget.studioId,
      'timestamp': Timestamp.now(),
    });

    // Update User Chat List
    await _firestore.collection('userChats').doc(widget.userId).set({
      'studios': FieldValue.arrayUnion([widget.studioId])
    }, SetOptions(merge: true));

    // Update Studio Chat List
    await _firestore.collection('studioChats').doc(widget.studioId).set({
      'users': FieldValue.arrayUnion([widget.userId])
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studioName, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
            SizedBox(height: 100),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index].data() as Map<String, dynamic>;
                      bool isSender = msg['senderId'] == widget.userId;
                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.blueAccent : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: Offset(2, 3),
                              )
                            ],
                          ),
                          child: Text(
                            msg['message'],
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 24,
                      child: Icon(Icons.send, color: Colors.white, size: 24),
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
