import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;

  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  void listenToPresence(RealtimeChannel channel) {
    channel.onRealtimeStatusChanged((status) {
      // التسمية الصحيحة لحالة القناة في نسختك الحالية
      if (status == RealtimeStatus.subscribed) {
        debugPrint('Subscribed to presence successfully!');
      }
    });

    channel.onPresenceSync((payload) {
      _onlineUsers.clear();
      // جلب البيانات الصحيحة المتوافقة مع نسختك الحالية
      final states = channel.presenceState();
      states.forEach((key, value) {
        for (var presence in value) {
          if (presence.rawPayload!= null && presence.rawPayload!['user_id']!= null) {
            _onlineUsers.add(presence.rawPayload!['user_id'] as String);
          } else if (presence.rawPayload!= null) {
            // حل بديل إضافي لضمان جلب الآيدي تحت أي مسمى داخل الخريطة
            final userId = presence.rawPayload!['id']?? presence.rawPayload!['userId'];
            if (userId!= null) _onlineUsers.add(userId as String);
          }
        }
      });
      notifyListeners();
    }).subscribe();
  }

  void clearOnlineUsers() {
    _onlineUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _onlineUsers.clear();
    super.dispose();
  }
}
