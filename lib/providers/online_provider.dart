import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة التي يستدعيها ملف main.dart
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // إنشاء القناة
    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. دالة المتابعة والمزامنة بالطريقة الصحيحة لحزمة فلاتر
  void listenToPresence(RealtimeChannel channel) {
    channel.onPresence(
      // تحديد نوع الحدث (المزامنة)
      RealtimePresenceConfig(event: 'sync'),
      (payload) {
        _onlineUsers.clear();
        
        // قراءة الـ states بطريقة مباشرة ومتوافقة مع نوع البيانات
        final List<dynamic> states = channel.presenceState();
        
        for (var state in states) {
          if (state is SinglePresenceState) {
            // جلب الأيدي إذا كان كائن جاهز
            final userId = state.rawPayload?['user_id'];
            if (userId != null) _onlineUsers.add(userId.toString());
          } else if (state is Map && state['user_id'] != null) {
            _onlineUsers.add(state['user_id'].toString());
          }
        }
        notifyListeners();
      },
    ).subscribe((status, [error]) {
      // التحقق من نجاح الاشتراك بالقناة لتتبع المستخدم الحالي
      if (status == RealtimeStatus.subscribed) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          _presenceChannel?.track({'user_id': user.id});
        }
      }
    });
  }

  // 3. الدالة التي تطلبها شاشة الدردشات chat_list_screen.dart
  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}
