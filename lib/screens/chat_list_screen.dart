import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/unread_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import '../utils/supabase_client.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    try {
      final res = await supabase
          .from('room_members')
          .select('''
            room_id,
            rooms (
              id,
              name,
              room_type,
              avatar_url,
              updated_at,
              last_message:messages(content, created_at, user_id, profiles(username, avatar_url))
            )
          ''')
          .eq('user_id', userId)
          .order('rooms(updated_at)', ascending: false);

      setState(() {
        _rooms = (res as List).map((e) => e['rooms'] as Map<String, dynamic>).toList();
        _loading = false;
      });

      // حمل العدادات
      context.read<UnreadProvider>().loadUnread(userId);
    } catch (e) {
      print('Error loading rooms: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadProvider = context.watch<UnreadProvider>();
    final appName = context.watch<AppSettingsProvider>().settings.appName;

    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        actions: [
          // زر البحث
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
          // زر الإعدادات
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد محادثات بعد',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابحث عن أصدقاء وابدأ محادثة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      final roomId = room['id'] as String;
                      final unreadCount = unreadProvider.roomUnread[roomId]?? 0;
                      final lastMsg = room['last_message'] as List?;

                      String lastMessageText = 'ابدأ المحادثة';
                      String lastMessageTime = '';
                      
                      if (lastMsg!= null && lastMsg.isNotEmpty) {
                        final msg = lastMsg.first;
                        lastMessageText = msg['content']?? '';
                        final createdAt = DateTime.parse(msg['created_at']);
                        lastMessageTime = _formatTime(createdAt);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: GlassContainer(
                          onTap: () {
                            Navigator.of(context).pushNamed('/chat/$roomId');
                          },
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // الصورة
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                backgroundImage: room['avatar_url']!= null
                                    ? NetworkImage(room['avatar_url'])
                                    : null,
                                child: room['avatar_url'] == null
                                    ? Icon(
                                        room['room_type'] == 'group'
                                            ? Icons.group_rounded
                                            : Icons.person_rounded,
                                        color: AppColors.primary,
                                        size: 28,
                                      )
                                    : null,
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // النصوص
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room['name']?? 'محادثة',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          lastMessageTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 4),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lastMessageText,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontFamily: 'Cairo',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (unreadCount > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              unreadCount > 99 ? '99+' : '$unreadCount',
                                              style: const TextStyle(
                                                color: AppColors.primaryForeground,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/search');
        },
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      // اليوم - اعرض الساعة
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'م' : 'ص';
      return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} أيام';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
