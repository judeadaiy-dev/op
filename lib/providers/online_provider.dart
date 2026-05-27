import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة النظامية التي يستدعيها ملف main.dart
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. دالة المتابعة والمزامنة بالاعتماد على الأنواع الدقيقة للحزمة الحالية
  void listenToPresence(RealtimeChannel channel) {
    channel.onPresenceSync((payload) {
      _onlineUsers.clear();
      
      // التوافق مع النوع القياسي المطلق في السجل: List<SinglePresenceState>
      final List<dynamic> states = channel.presenceState();
      
      for (var state in states) {
        // الوصول للـ user_id النظامي بأمان تام
        if (state is Map) {
          final userId = state['user_id'];
          if (userId != null) _onlineUsers.add(userId.toString());
        } else {
          try {
            // قراءة الـ user_id من الـ payload للكائن الممرر
            final userId = state.payload?['user_id'];
            if (userId != null) _onlineUsers.add(userId.toString());
          } catch (_) {
            // محاولة قراءة احتياطية في حال اختلاف مسمى الخاصية داخلياً
            try {
              final userId = (state as dynamic).rawPayload?['user_id'];
              if (userId != null) _onlineUsers.add(userId.toString());
            } catch (_) {}
          }
        }
      }
      notifyListeners();
    }).subscribe((status, [error]) {
      // التحقق النظامي من حالة الاشتراك عن طريق تحويل الـ Enum لنص صريح لتفادي غياب الكلاس
      if (status.toString().contains('subscribed') || status.toString().contains('SUBSCRIBED')) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          _presenceChannel?.track({'user_id': user.id});
        }
      }
    });
  }

  // 3. الدالة التي تطلبها شاشة chat_list_screen.dart
  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}
