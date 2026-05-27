import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnreadProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  int _totalUnread = 0;
  final Map<String, int> _roomUnreadCounts = {};

  int get totalUnread => _totalUnread;
  Map<String, int> get roomUnreadCounts => _roomUnreadCounts;

  Future<void> fetchUnreadCounts() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // الطريقة الجديدة لحساب العدد
      final response = await supabase
         .from('messages')
         .select()
         .eq('read', false)
         .neq('sender_id', userId)
         .count(CountOption.exact);

      final count = response.count;
      _totalUnread = count.toInt();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread counts: $e');
    }
  }

  Future<void> fetchRoomUnreadCount(String roomId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
         .from('messages')
         .select()
         .eq('room_id', roomId)
         .eq('read', false)
         .neq('sender_id', userId)
         .count(CountOption.exact);

      final count = response.count;
      _roomUnreadCounts[roomId] = count.toInt();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching room unread count: $e');
    }
  }

  void markRoomAsRead(String roomId) {
    _roomUnreadCounts[roomId] = 0;
    _totalUnread = _roomUnreadCounts.values.fold(0, (sum, count) => sum + count);
    notifyListeners();
  }
}
