import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique chat ID based on sender and receiver IDs
  String get chatId {
    List<String> ids = [widget.senderId, widget.receiverId];
    ids.sort(); // Ensure the chat ID is always the same for two users
    return '${ids[0]}_${ids[1]}';
  }

  // Send a message to Firestore
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add the message to the Firestore collection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'timestamp': Timestamp.now(),
    });

    // Update the last message in the chat document
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [widget.senderId, widget.receiverId],
      'lastMessage': message,
      'timestamp': Timestamp.now(),
    }, SetOptions(merge: true));

    // Clear the message input field
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index].data() as Map<String, dynamic>;
                      bool isSender = msg['senderId'] == widget.senderId;

                      // Align messages to the right if the sender is the current user, otherwise to the left
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSender
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['message'],
                            style: TextStyle(
                              color: isSender
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(14),
                      child: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
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
