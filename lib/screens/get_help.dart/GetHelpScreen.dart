import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GetHelpScreen extends StatefulWidget {
  const GetHelpScreen({super.key});

  @override
  State<GetHelpScreen> createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends State<GetHelpScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? chatId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .limit(1)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      setState(() {
        chatId = chatQuery.docs.first.id;
      });
    } else {
      final newChat = await _firestore.collection('chats').add({
        'participants': [user.uid, 'admin'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        chatId = newChat.id;
      });
    }
  }

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || chatId == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    setState(() {}); // Updates send button state

    // Smooth scroll to bottom (latest message)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final timestamp = (msg['createdAt'] is Timestamp)
        ? (msg['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              child: const Icon(Icons.support_agent, size: 20),
              backgroundColor: Colors.grey[400],
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      )
                    : LinearGradient(
                        colors: [Colors.grey[300]!, Colors.grey[200]!],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg['message'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 18,
              child: const Icon(Icons.person, size: 20),
              backgroundColor: Colors.blueAccent,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to chat.'))
          : Column(
              children: [
                Expanded(
                  child: chatId == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .doc(chatId)
                              .collection('messages')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final messages = snapshot.data!.docs;

                            // Auto scroll on new messages
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });

                            return ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe = msg['senderId'] == user.uid;
                                return _buildMessageBubble(
                                    msg.data() as Map<String, dynamic>, isMe);
                              },
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.redAccent,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _messageController.text.trim().isEmpty
                                ? null
                                : _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
