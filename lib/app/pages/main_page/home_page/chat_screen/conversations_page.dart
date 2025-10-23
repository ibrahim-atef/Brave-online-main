import 'package:flutter/material.dart';
import 'package:webinar/common/components.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../services/guest_service/course_service.dart';
import 'chat_screen.dart';

class ConversationsPage extends StatefulWidget {
  static const String pageName = '/ConversationsPage';

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  int? passedCourseId;
  String? courseTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (passedCourseId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      passedCourseId = args?['courseId'];
      courseTitle = args?['title'];
      if (passedCourseId != null) {
        fetchConversationForCourse(passedCourseId!);
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchConversationForCourse(int courseId) async {
    final value = await CourseService.fetchConversationId(course_id: courseId);
    print('[DEBUG] Conversation ID: $value');
    try {
      if (value != null && value != "Error" && value['id'] != null) {
        setState(() {
          conversations = [
            {
              'id': value['id'],
              'course_id': courseId,
            }
          ];
        });
      }
    } catch (e) {
      print('[DEBUG] ❌ Error parsing conversation: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(title: 'قائمة المحادثات'),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("جاري تحميل المحادثات...", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : conversations.isEmpty
              ? Center(child: Text('لا توجد محادثات متاحة.'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final convo = conversations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ChatScreen.pageName,
                          arguments: {
                            'courseId': convo['course_id'],
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.yellow.withOpacity(0.1),
                            child: Icon(Icons.message, color: Colors.yellow, size: 28),
                          ),
                          title: Text(
                            courseTitle ?? 'بدون عنوان',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'رقم المحادثة: ${convo['id']}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
