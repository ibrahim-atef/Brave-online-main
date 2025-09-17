import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import '../../../../../common/data/app_data.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../services/guest_service/course_service.dart';
import 'package:webinar/common/components.dart';

class ChatScreen extends StatefulWidget {
  static const String pageName = '/ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late PusherChannelsFlutter pusher;
  List<Map<String, dynamic>> messages = [];
  String? conversationId;
  int? courseId;
  int? currentUserId;
  String? userName;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final ImagePicker _picker = ImagePicker();
  bool isRecording = false;
  String? recordedFilePath;
  bool _initialized = false;
  bool _isLoading = true;
  bool isPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      courseId = args['courseId'];
      fetchConversationId();
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _player.openPlayer();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final id = await AppData.getUserId();
    final name = await AppData.getName();
    setState(() {
      currentUserId = id; // بدون تحويل
      userName = name?.toString() ?? '';
    });
    print('currentUserId: $currentUserId');
  }

  Future<void> fetchConversationId() async {
    final value = await CourseService.fetchConversationId(course_id: courseId);
    try {
      if (value != null && value != "Error" && value['id'] != null) {
        setState(() {
          conversationId = value['id'].toString();
          messages = List<Map<String, dynamic>>.from(value['messages'] ?? []);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollToBottom();
});

        await initPusher(conversationId!);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> initPusher(String convId) async {
    try {
      String token = await AppData.getAccessToken();
      pusher = PusherChannelsFlutter.getInstance();
      await pusher.init(
        apiKey: "3ba66a8f6e55f3d843e0",
        cluster: "eu",
        authEndpoint: "${Constants.dommain}/broadcasting/auth",
        authParams: {
          "headers": {
            "Authorization": "Bearer $token",
          }
        },
        onEvent: (event) async {
          if (event.eventName == "message.sent" && event.data is String) {
            try {
              final data = jsonDecode(event.data);
              setState(() {
  // إذا كانت الرسالة موجودة بالفعل لا تضفها
  if (!messages.any((m) => m['id'] == data['id'] && data['id'] != null)) {
    messages.add(Map<String, dynamic>.from(data));
  }
});
              _scrollToBottom();
            } catch (_) {}
          }
        },
      );
      await pusher.connect();
      await pusher.subscribe(channelName: "conversation.$convId");
    } catch (_) {} finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty || conversationId == null || currentUserId == null) return;
    final success = await CourseService.sendMessage(
      conversationId: int.parse(conversationId!),
      message: msg,
    );
    if (success) {
      _controller.clear();
      _scrollToBottom();
      // لا تضف الرسالة محلياً، انتظر وصولها من Pusher
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال الرسالة')),
      );
    }
  }

  Future<void> sendMediaMessage(XFile file) async {
    if (conversationId == null || currentUserId == null) return;
    _showLoader();
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final success = await CourseService.sendMessageWithFile(
      conversationId: int.parse(conversationId!),
      message: '',
      file: File(file.path),
      fileMimeType: mimeType,
    );
    _hideLoader();
    if (success) {
      _scrollToBottom();
      // لا تضف الرسالة محلياً، انتظر وصولها من Pusher
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الملف')),
      );
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await sendMediaMessage(image);
  }

  Future<void> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await sendMediaMessage(video);
  }

  Future<void> startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب السماح باستخدام الميكروفون')),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
    setState(() {
      isRecording = true;
      recordedFilePath = path;
    });
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
    if (recordedFilePath != null) {
      await sendMediaMessage(XFile(recordedFilePath!));
    }
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      await sendMediaMessage(XFile(result.files.single.path!));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLoader([String msg = 'جاري الرفع...']) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _hideLoader() => Navigator.of(context, rootNavigator: true).pop();

  Widget _buildMediaWidget(String mediaUrl) {
    final ext = mediaUrl.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          mediaUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            final v = progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 200, height: 200, color: Colors.black12),
                CircularProgressIndicator(value: v),
              ],
            );
          },
          errorBuilder: (_, __, ___) =>
              const Text('❌ تعذّر تحميل الصورة', style: TextStyle(fontSize: 12)),
        ),
      );
    }
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      return SizedBox(width: 200, child: InlineVideoPlayer(url: mediaUrl));
    }
    if (['aac', 'mp3', 'wav'].contains(ext)) {
      return Row(
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.blue),
            onPressed: () async {
              if (isPlaying) {
                await _player.stopPlayer();
                setState(() => isPlaying = false);
              } else {
                await _player.startPlayer(
                  fromURI: mediaUrl,
                  whenFinished: () => setState(() => isPlaying = false),
                );
                setState(() => isPlaying = true);
              }
            },
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('تشغيل ملف صوتي')),
        ],
      );
    }
    if (ext == 'pdf') {
      return InkWell(
        onTap: () async {
              if (mediaUrl.startsWith('/')) {
                await OpenFile.open(mediaUrl);
              } else {
                final tempDir = await getTemporaryDirectory();
                final filePath = '${tempDir.path}/${mediaUrl.split('/').last}';
                final file = File(filePath);
                if (!await file.exists()) {
                  final response = await http.get(Uri.parse(mediaUrl));
                  await file.writeAsBytes(response.bodyBytes);
                }
                await OpenFile.open(filePath);
              }
        },
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ملف PDF',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () async {
                if (mediaUrl.startsWith('/')) {
                  await OpenFile.open(mediaUrl);
                } else {
                  final tempDir = await getTemporaryDirectory();
                  final filePath = '${tempDir.path}/${mediaUrl.split('/').last}';
                  final file = File(filePath);
                  if (!await file.exists()) {
                    final response = await http.get(Uri.parse(mediaUrl));
                    await file.writeAsBytes(response.bodyBytes);
                  }
                  await OpenFile.open(filePath);
                }
              },
            ),
          ],
        ),
      );
    }
    return const Text('📎 مرفق');
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    pusher.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(title: "المحادثة"),
      body: _isLoading || currentUserId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("جاري تحميل المحادثة...", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final message = messages[index];
                        final mediaUrl = message['attachment_url'] ?? message['media_url'];
                        final isMe = message['sender_id']?.toString() == currentUserId?.toString();
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? 'أنت' : (message['sender_name'] ?? ''),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                if (mediaUrl != null) ...[
                                  _buildMediaWidget(mediaUrl),
                                  if ((message['content'] ?? '').toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: GestureDetector(
                                        onLongPress: () {
                                          final text = message['content'] ?? '';
                                          if (text.isNotEmpty) {
                                            Clipboard.setData(ClipboardData(text: text));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('تم نسخ الرسالة')),
                                            );
                                          }
                                        },
                                        child: Text(
                                          message['content'] ?? '',
                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 6),
                                ] else if ((message['content'] ?? '').toString().isNotEmpty) ...[
                                  GestureDetector(
                                    onLongPress: () {
                                      final text = message['content'] ?? '';
                                      if (text.isNotEmpty) {
                                        Clipboard.setData(ClipboardData(text: text));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('تم نسخ الرسالة')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      message['content'] ?? '',
                                      style: TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                ],
                                SizedBox(height: 6),
                                Text(
                                  message['created_at']?.toString().split('T')[0] ?? '',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "اكتب رسالتك...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: pickImage,
                      ),
                      IconButton(
                        icon: Icon(Icons.videocam),
                        onPressed: pickVideo,
                      ),
                      IconButton(
                        icon: Icon(isRecording ? Icons.stop : Icons.mic),
                        onPressed: () async {
                          if (isRecording) {
                            await stopRecording();
                          } else {
                            await startRecording();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: pickDocument,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
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

class InlineVideoPlayer extends StatefulWidget {
  final String url;
  const InlineVideoPlayer({super.key, required this.url});
  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _playing = false);
    } else {
      _controller.play();
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ready
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(
                  width: 200,
                  height: 200,
                  color: Colors.black12,
                ),
          if (!_ready)
            const CircularProgressIndicator(strokeWidth: 2),
          if (_ready && !_playing)
            const Icon(Icons.play_circle, size: 50, color: Colors.white70),
        ],
      ),
    );
  }
}

