import 'package:flutter/material.dart';
import '../utils/supabase_client.dart';

class UnreadProvider extends ChangeNotifier {
  int _totalUnread = 0;
  Map<String, int> _roomUnread = {};

  int get totalUnread => _totalUnread;
  Map<String, int> get roomUnread => _roomUnread;

  UnreadProvider();

  Future<void> loadUnread(String userId) async {
    try {
      // 1. جيب كل الغرف اللي المستخدم عضو فيها
      final memberRooms = await supabase
         .from('room_members')
         .select('room_id')
         .eq('user_id', userId);

      final roomIds = (memberRooms as List).map((e) => e['room_id'] as String).toList();

      if (roomIds.isEmpty) {
        _totalUnread = 0;
        _roomUnread = {};
        notifyListeners();
        return;
      }

      // 2. جيب آخر قراءة لكل غرفة
      final reads = await supabase
         .from('room_reads')
         .select('room_id, last_read_at')
         .eq('user_id', userId);

      final readMap = <String, String>{};
      for (var r in reads as List) {
        readMap[r['room_id']] = r['last_read_at'];
      }

      // 3. احسب الرسائل غير المقروءة لكل غرفة
      _roomUnread = {};
      _totalUnread = 0;

      for (var roomId in roomIds) {
        final lastRead = readMap[roomId]?? '1970-01-01T00:00:00Z';
        final countRes = await supabase
           .from('messages')
           .select('id', const FetchOptions(count: CountOption.exact))
           .eq('room_id', roomId)
           .gt('created_at', lastRead)
           .neq('user_id', userId);

        final count = countRes.count?? 0;
        if (count > 0) {
          _roomUnread[roomId] = count;
          _totalUnread += count;
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading unread: $e');
    }
  }

  Future<void> markAsRead(String userId, String roomId) async {
    try {
      await supabase.from('room_reads').upsert({
        'user_id': userId,
        'room_id': roomId,
        'last_read_at': DateTime.now().toIso8601String(),
      });

      // حدث العداد محلياً
      if (_roomUnread.containsKey(roomId)) {
        _totalUnread -= _roomUnread[roomId]!;
        _roomUnread.remove(roomId);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  void increment(String roomId) {
    _roomUnread[roomId] = (_roomUnread[roomId]?? 0) + 1;
    _totalUnread++;
    notifyListeners();
  }

  void clear() {
    _totalUnread = 0;
    _roomUnread = {};
    notifyListeners();
  }
}
