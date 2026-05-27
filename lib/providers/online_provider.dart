import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة التي يطلبها ملف main.dart
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // إنشاء القناة واستهداف الـ presence
    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. دالة الاستماع والمزامنة المتوافقة تماماً مع نسخة 2.7.x
  void listenToPresence(RealtimeChannel channel) {
    channel
        .onEvents(
          RealtimeListenTypes.presence,
          ChannelFilter(event: 'sync'),
          (payload, [ref]) {
            _onlineUsers.clear();
            
            // جلب الحالات بطريقة ديناميكية آمنة لتفادي أخطاء المسميات والـ Getters
            final List<dynamic> states = channel.presenceState();
            
            for (var state in states) {
              // الحزمة تعيد كائنات تحتوي على الـ payloads داخل قائمة الخصائص بشكل ديناميكي
              if (state is Map) {
                final userId = state['user_id'];
                if (userId != null) _onlineUsers.add(userId.toString());
              } else {
                try {
                  // محاولة قراءة الـ payload بأمان في حال تمرير الكائن بصيغة SinglePresenceState
                  final dynamic payloadData = (state as dynamic).payload;
                  if (payloadData != null && payloadData['user_id'] != null) {
                    _onlineUsers.add(payloadData['user_id'].toString());
                  }
                } catch (_) {
                  // تجاوز أي خطأ قراءة فردي لضمان استمرار الدورة
                }
              }
            }
            notifyListeners();
          },
        )
        .subscribe((status, [error]) {
          // التحقق من نجاح الاشتراك بالاعتماد على الاسم النصي المباشر بدلاً من الكلاس الفارغ
          if (status.name.toUpperCase() == 'SUBSCRIBED') {
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
