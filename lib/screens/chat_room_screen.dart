import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/unread_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import '../utils/supabase_client.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;

  const ChatRoomScreen({super.key, required this.roomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _room;
  bool _loading = true;
  bool _sending = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
    _loadMessages();
    _markAsRead();
    _listenRealtime();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    try {
      final res = await supabase
         .from('rooms')
         .select('*')
         .eq('id', widget.roomId)
         .single();

      setState(() => _room = res);
    } catch (e) {
      print('Error loading room: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final res = await supabase
         .from('messages')
         .select('''
            id,
            content,
            message_type,
            media_url,
            created_at,
            user_id,
            profiles(username, avatar_url)
          ''')
         .eq('room_id', widget.roomId)
         .order('created_at', ascending: true);

      setState(() {
        _messages = (res as List).cast<Map<String, dynamic>>();
        _loading = false;
      });

      // اسكرول للأسفل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _loading = false);
    }
  }

  void _listenRealtime() {
    supabase
       .channel('room:${widget.roomId}')
       .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: 'eq',
            column: 'room_id',
            value: widget.roomId,
          ),
          callback: (payload) async {
            // جيب بيانات المرسل
            final userId = payload.newRecord['user_id'];
            final profile = await supabase
               .from('profiles')
               .select('username, avatar_url')
               .eq('id', userId)
               .single();

            final newMsg = {
             ...payload.newRecord,
              'profiles': profile,
            };

            setState(() => _messages.add(newMsg));

            // اسكرول للأسفل
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }

            // حدث العداد اذا مو مني
            final myId = context.read<AuthProvider>().user?.id;
            if (userId!= myId) {
              context.read<UnreadProvider>().increment(widget.roomId);
            }
          },
        )
       .subscribe();
  }

  Future<void> _markAsRead() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    await context.read<UnreadProvider>().markAsRead(userId, widget.roomId);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    setState(() => _sending = true);

    try {
      String? mediaUrl;

      // ارفع الصورة اذا موجودة
      if (_selectedImage!= null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'chat-media/$fileName';

        await supabase.storage
           .from('chat-media')
           .upload(path, _selectedImage!);

        mediaUrl = supabase.storage
           .from('chat-media')
           .getPublicUrl(path);
      }

      await supabase.from('messages').insert({
        'room_id': widget.roomId,
        'user_id': userId,
        'content': content,
        'message_type': mediaUrl!= null? 'image' : 'text',
        'media_url': mediaUrl,
      });

      // حدث آخر رسالة في الغرفة
      await supabase.from('rooms').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.roomId);

      _messageController.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الإرسال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image!= null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatBg = context.watch<AppSettingsProvider>().settings.chatBackgroundUrl;
    final myId = context.watch<AuthProvider>().user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: _room?['avatar_url']!= null
                 ? NetworkImage(_room!['avatar_url'])
                  : null,
              child: _room?['avatar_url'] == null
                 ? Icon(
                      _room?['room_type'] == 'group'
                         ? Icons.group_rounded
                          : Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _room?['name']?? 'محادثة',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'متصل الآن',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              // خيارات الغرفة
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: chatBg!= null
             ? DecorationImage(
                  image: NetworkImage(chatBg),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                )
              : null,
        ),
        child: Column(
          children: [
            // الرسائل
            Expanded(
              child: _loading
                 ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                     ? Center(
                          child: Text(
                            'لا توجد رسائل بعد\nابدأ المحادثة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg['user_id'] == myId;
                            final profile = msg['profiles'];

                            return _buildMessageBubble(msg, profile, isMe);
                          },
                        ),
            ),

            // معاينة الصورة المختارة
            if (_selectedImage!= null)
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ),
                  ],
                ),
              ),

            // شريط الإرسال
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.all(8),
              borderRadius: 28,
              child: Row(
                children: [
                  // زر الصورة
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: _sending? null : _pickImage,
                  ),

                  // حقل النص
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      enabled:!_sending,
                    ),
                  ),

                  // زر الإرسال
                  IconButton(
                    icon: _sending
                       ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    color: AppColors.primary,
                    onPressed: _sending? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> msg,
    Map<String, dynamic>? profile,
    bool isMe,
  ) {
    final hasMedia = msg['media_url']!= null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)...[
            CircleAvatar(
              radius: 16,
              backgroundImage: profile?['avatar_url']!= null
                 ? NetworkImage(profile!['avatar_url'])
                  : null,
              child: profile?['avatar_url'] == null
                 ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                   ? AppColors.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe? 20 : 4),
                  bottomRight: Radius.circular(isMe? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      profile?['username']?? 'مستخدم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 4),

                  if (hasMedia)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        msg['media_url'],
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

                  if (msg['content']!= null && msg['content'].isNotEmpty)...[
                    if (hasMedia) const SizedBox(height: 8),
                    Text(
                      msg['content'],
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe
                           ? AppColors.primaryForeground
                            : Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(DateTime.parse(msg['created_at'])),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                         ? AppColors.primaryForeground.withOpacity(0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour > 12? time.hour - 12 : time.hour;
    final period = time.hour >= 12? 'م' : 'ص';
    return '${hour == 0? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
