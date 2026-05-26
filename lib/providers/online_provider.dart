import 'package:flutter/material.dart';
import '../utils/supabase_client.dart';

class OnlineProvider extends ChangeNotifier {
  final Map<String, bool> _onlineStatus = {};
  final Map<String, String> _lastSeen = {};

  Map<String, bool> get onlineStatus => _onlineStatus;
  Map<String, String> get lastSeen => _lastSeen;

  OnlineProvider();

  void updateUserStatus(String userId, bool isOnline, String? lastSeenAt) {
    _onlineStatus[userId] = isOnline;
    if (lastSeenAt!= null) {
      _lastSeen[userId] = lastSeenAt;
    }
    notifyListeners();
  }

  bool isUserOnline(String userId) {
    return _onlineStatus[userId]?? false;
  }

  String? getLastSeen(String userId) {
    return _lastSeen[userId];
  }

  Future<void> updateMyStatus(bool isOnline) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('profiles').update({
        'last_seen_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // Presence channel
      final channel = supabase.channel('online-users');
      if (isOnline) {
        channel.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            channel.track({'user_id': user.id, 'online_at': DateTime.now().toIso8601String()});
          }
        });
      } else {
        await channel.untrack();
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  void listenToPresence() {
    final channel = supabase.channel('online-users');

    channel
       .onPresenceSync((payload) {
          final presences = channel.presenceState();
          _onlineStatus.clear();
          for (var presence in presences) {
            final userId = presence.payload['user_id'];
            if (userId!= null) {
              _onlineStatus[userId] = true;
            }
          }
          notifyListeners();
        })
       .onPresenceJoin((payload) {
          final userId = payload.newPresences.first.payload['user_id'];
          if (userId!= null) {
            _onlineStatus[userId] = true;
            notifyListeners();
          }
        })
       .onPresenceLeave((payload) {
          final userId = payload.leftPresences.first.payload['user_id'];
          if (userId!= null) {
            _onlineStatus[userId] = false;
            notifyListeners();
          }
        })
       .subscribe();
  }
}
