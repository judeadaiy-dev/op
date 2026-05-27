import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة التي يطلبها ملف main.dart عند تشغيل التطبيق
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // إنشاء القناة وتتبع حالة المستخدمين
    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. الدالة الداخلية لإدارة الاستماع والـ Sync
  void listenToPresence(RealtimeChannel channel) {
    channel.on(
      RealtimeListenTypes.presence,
      ChannelFilter(event: 'sync'),
      (payload, [ref]) {
        _onlineUsers.clear();
        
        // الطريقة الصحيحة والمضمونة لقراءة الـ states في حزمتك الحالية دون التسبب في خطأ Type
        final List<dynamic> states = channel.presenceState();
        
        for (var state in states) {
          if (state is Map && state['user_id'] != null) {
            _onlineUsers.add(state['user_id'].toString());
          } else if (state.rawPayload != null && state.rawPayload['user_id'] != null) {
            _onlineUsers.add(state.rawPayload['user_id'].toString());
          }
        }
        notifyListeners();
      },
    );

    channel.on(
      RealtimeListenTypes.presence,
      ChannelFilter(event: 'join'),
      (payload, [ref]) {
        debugPrint('مستخدم جديد دخل أونلاين');
      },
    );

    channel.subscribe((status, [error]) {
      if (status == 'SUBSCRIBED') {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // تسجيل دخول المستخدم الحالي في الـ Presence
          _presenceChannel?.track({'user_id': user.id});
        }
      }
    });
  }

  // 3. الدالة التي تطلبها شاشة chat_list_screen.dart لفحص حالة المستخدم
  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}
