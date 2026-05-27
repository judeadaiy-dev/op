import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import '../utils/supabase_client.dart';
import 'package:chat_app/theme/app_colors.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _users = [];
        _messages = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    final myId = context.read<AuthProvider>().user?.id;

    try {
      // البحث عن المستخدمين
      final usersRes = await supabase
          .from('profiles')
          .select('id, username, avatar_url, last_seen_at')
          .neq('id', myId?? '')
          .or('username.ilike.%$query%')
          .limit(20);

      // البحث في الرسائل
      final messagesRes = await supabase
          .from('messages')
          .select('''
            id,
            content,
            created_at,
            room_id,
            user_id,
            rooms(name, room_type),
            profiles(username, avatar_url)
          ''')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _users = (usersRes as List).cast<Map<String, dynamic>>();
        _messages = (messagesRes as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _startChatWithUser(String userId, String username) async {
    final myId = context.read<AuthProvider>().user?.id;
    if (myId == null) return;

    try {
      // تحقق اذا فيه محادثة موجودة
      final existingRooms = await supabase
          .from('room_members')
          .select('room_id, rooms!inner(room_type)')
          .eq('user_id', myId);

      String? roomId;

      for (var rm in existingRooms as List) {
        if (rm['rooms']['room_type'] == 'direct') {
          final members = await supabase
              .from('room_members')
              .select('user_id')
              .eq('room_id', rm['room_id']);

          final memberIds = (members as List).map((m) => m['user_id']).toList();
          if (memberIds.length == 2 && memberIds.contains(userId)) {
            roomId = rm['room_id'];
            break;
          }
        }
      }

      // اذا ما فيه، انشئ محادثة جديدة
      if (roomId == null) {
        final newRoom = await supabase
            .from('rooms')
            .insert({
              'name': username,
              'room_type': 'direct',
              'created_by': myId,
            })
            .select('id')
            .single();

        roomId = newRoom['id'];

        // ضيف العضوين
        await supabase.from('room_members').insert([
          {'room_id': roomId, 'user_id': myId},
          {'room_id': roomId, 'user_id': userId},
        ]);
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/chat/$roomId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الأشخاص'),
            Tab(text: 'الرسائل'),
          ],
        ),
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن أشخاص أو رسائل...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  // بحث مع debounce
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      _performSearch(value);
                    }
                  });
                },
              ),
            ),
          ),

          // النتائج
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ابحث عن أصدقاء أو رسائل',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // تبويب الأشخاص
                          _buildUsersTab(),
                          // تبويب الرسائل
                          _buildMessagesTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Cairo',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            onTap: () => _startChatWithUser(user['id'], user['username']),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user['avatar_url']!= null
                      ? NetworkImage(user['avatar_url'])
                      : null,
                  child: user['avatar_url'] == null
                      ? const Icon(Icons.person_rounded)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['username']?? 'مستخدم',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'اضغط لبدء محادثة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chat_bubble_outline_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Cairo',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final room = msg['rooms'];
        final profile = msg['profiles'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            onTap: () {
              Navigator.of(context).pushNamed('/chat/${msg['room_id']}');
            },
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: profile?['avatar_url']!= null
                          ? NetworkImage(profile['avatar_url'])
                          : null,
                      child: profile?['avatar_url'] == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${profile?['username']?? 'مستخدم'} في ${room?['name']?? 'محادثة'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(DateTime.parse(msg['created_at'])),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  msg['content']?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      final hour = time.hour > 12? time.hour - 12 : time.hour;
      final period = time.hour >= 12? 'م' : 'ص';
      return '${hour == 0? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
