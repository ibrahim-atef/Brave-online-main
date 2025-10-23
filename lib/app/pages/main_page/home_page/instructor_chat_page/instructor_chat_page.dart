import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

class InstructorChatPage extends StatefulWidget {
  static const String pageName = '/instructor-chat-page';
  const InstructorChatPage({super.key});

  @override
  State<InstructorChatPage> createState() => _InstructorChatPageState();
}

class _InstructorChatPageState extends State<InstructorChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? instructorId;
  String? instructorName;
  String? userId;
  String? chatId;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      instructorId = args['instructorId']?.toString();
      instructorName = args['instructorName'] ?? 'Instructor';
      userId = locator<UserProvider>().profile?.id?.toString();
      
      if (userId != null && instructorId != null) {
        // Create unique chat ID by combining user IDs
        List<String> ids = [userId!, instructorId!];
        ids.sort(); // Sort to ensure consistent chat ID regardless of who starts the chat
        chatId = '${ids[0]}_${ids[1]}';
      }
      
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || chatId == null) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('instructor_chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': message,
        'senderId': userId,
        'senderName': locator<UserProvider>().profile?.fullName ?? 'Student',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update chat metadata
      await FirebaseFirestore.instance
          .collection('instructor_chats')
          .doc(chatId)
          .set({
        'participants': [userId, instructorId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'instructorId': instructorId,
        'instructorName': instructorName,
        'studentId': userId,
        'studentName': locator<UserProvider>().profile?.fullName ?? 'Student',
      }, SetOptions(merge: true));

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إرسال الرسالة: $e')),
      );
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, bool isMe) {
    final timestamp = messageData['timestamp'] as Timestamp?;
    final timeString = timestamp != null 
        ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? mainColor() : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              messageData['text'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            if (timeString.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeString,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return directionality(
        child: Scaffold(
          appBar: appbar(title: 'محادثة المدرب'),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return directionality(
      child: Scaffold(
        appBar: appbar(
          title: 'محادثة مع $instructorName',
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('instructor_chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('خطأ: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data?.docs ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد رسائل بعد\nابدأ المحادثة مع المدرب',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      final isMe = messageData['senderId'] == userId;
                      
                      return _buildMessageBubble(messageData, isMe);
                    },
                  );
                },
              ),
            ),

            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: mainColor()),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mainColor(),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
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
