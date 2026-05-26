import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_models.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _tab = "pending"; // pending, rooms, users, reports
  AdminStats _stats = AdminStats(users: 0, rooms: 0, messagesToday: 0, pending: 0, reports: 0);
  List<Room> _rooms = [];
  List<Room> _pendingRooms = [];
  List<UserRow> _users = [];
  List<UserReport> _reports = [];
  bool _loading = true;
  UserReport? _selectedReport;
  String _responseMsg = "";
  String _responseTarget = "reporter"; // reporter, reported
  String _actionTaken = "none"; // none, warning, ban
  bool _working = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    try {
      final results = await Future.wait([
        supabase.from("profiles").select("id").count(),
        supabase.from("rooms").select("id").eq("status", "approved").count(),
        supabase.from("messages").select("id").gte("created_at", todayStart.toIso8601String()).count(),
        supabase.from("rooms").select("id").eq("status", "pending").count(),
        supabase.from("user_reports").select("id").eq("status", "pending").count(),
        supabase.from("rooms").select("*").eq("status", "approved").order("created_at", ascending: false),
        supabase.from("rooms").select("*").eq("status", "pending").order("created_at", ascending: false),
        supabase.from("profiles").select("*").order("created_at", ascending: false),
        supabase.from("user_roles").select("user_id, role"),
        supabase.from("user_reports").select("*, reporter:profiles!user_reports_reporter_id_fkey(*), reported:profiles!user_reports_reported_id_fkey(*)").order("created_at", ascending: false),
      ]);

      setState(() {
        _stats = AdminStats(
          users: results[0].count?? 0,
          rooms: results[1].count?? 0,
          messagesToday: results[2].count?? 0,
          pending: results[3].count?? 0,
          reports: results[4].count?? 0,
        );
        _rooms = (results[5] as List).map((e) => Room.fromJson(e)).toList();
        _pendingRooms = (results[6] as List).map((e) => Room.fromJson(e)).toList();

        // دمج المستخدمين مع الأدوار
        final rolesData = results[8] as List;
        final roleMap = <String, List<String>>{};
        for (var r in rolesData) {
          roleMap.putIfAbsent(r['user_id'], () => []).add(r['role']);
        }
        _users = (results[7] as List).map((e) => UserRow.fromJson({...e, 'roles': roleMap[e['id']]?? []})).toList();

        _loading = false;
      });
    } catch (e) {
      _showToast('فشل التحديث', isError: true);
      setState(() => _loading = false);
    }
  }

  Future<void> _approveRoom(String id) async {
    final room = _pendingRooms.firstWhere((r) => r.id == id);
    final res = await supabase.from("rooms").update({"status": "approved"}).eq("id", id);
    if (res.error!= null) {
      _showToast("فشل", isError: true);
    } else {
      await supabase.from("notifications").insert({
        "user_id": room.ownerId,
        "type": "room_approved",
        "title": "تم اعتماد غرفتك ✅",
        "body": 'الغرفة "${room.name}" أصبحت متاحة للجميع',
        "link": "/chat/${room.id}",
      });
      _showToast("اعتُمدت");
      _refresh();
    }
  }

  Future<void> _rejectRoom(String id) async {
    final confirm = await _showConfirm("رفض الغرفة؟");
    if (!confirm) return;
    final room = _pendingRooms.firstWhere((r) => r.id == id);
    final res = await supabase.from("rooms").update({"status": "rejected"}).eq("id", id);
    if (res.error!= null) {
      _showToast("فشل", isError: true);
    } else {
      await supabase.from("notifications").insert({
        "user_id": room.ownerId,
        "type": "room_rejected",
        "title": "تم رفض غرفتك ❌",
        "body": 'الغرفة "${room.name}" لم تُعتمد',
        "link": "/rooms",
      });
      _showToast("رُفضت");
      _refresh();
    }
  }

  Future<void> _deleteRoom(String id) async {
    final confirm = await _showConfirm("حذف الغرفة وجميع رسائلها؟");
    if (!confirm) return;
    final res = await supabase.from("rooms").delete().eq("id", id);
    if (res.error!= null) {
      _showToast("فشل الحذف", isError: true);
    } else {
      _showToast("حُذفت");
      _refresh();
    }
  }

  Future<void> _toggleRoomClose(Room room) async {
    final res = await supabase.from("rooms").update({"is_closed":!room.isClosed}).eq("id", room.id);
    if (res.error!= null) {
      _showToast("فشل", isError: true);
    } else {
      _showToast(room.isClosed? "فُتحت" : "أُغلقت");
      _refresh();
    }
  }

  Future<void> _toggleBan(UserRow u) async {
    if (u.id == supabase.auth.currentUser?.id) {
      _showToast("لا يمكن حظر نفسك", isError: true);
      return;
    }
    final res = await supabase.from("profiles").update({"is_banned":!u.isBanned}).eq("id", u.id);
    if (res.error!= null) {
      _showToast("فشل", isError: true);
    } else {
      _showToast(u.isBanned? "رُفع الحظر" : "تم الحظر");
      _refresh();
    }
  }

  Future<void> _toggleAdmin(UserRow u) async {
    if (u.id == supabase.auth.currentUser?.id) {
      _showToast("لا يمكن تعديل دورك", isError: true);
      return;
    }
    final isAdminUser = u.roles.contains("admin");
    if (isAdminUser) {
      final res = await supabase.from("user_roles").delete().eq("user_id", u.id).eq("role", "admin");
      if (res.error!= null) {
        _showToast("فشل", isError: true);
      } else {
        _showToast("أُلغيت صلاحية الأدمن");
        _refresh();
      }
    } else {
      final res = await supabase.from("user_roles").insert({"user_id": u.id, "role": "admin"});
      if (res.error!= null) {
        _showToast("فشل", isError: true);
      } else {
        _showToast("صار أدمن");
        _refresh();
      }
    }
  }

  Future<void> _sendReportResponse() async {
    if (_selectedReport == null || _responseMsg.trim().isEmpty) return;
    setState(() => _working = true);

    final me = supabase.auth.currentUser;
    if (me == null) return;

    final targetId = _responseTarget == "reporter"? _selectedReport!.reporterId : _selectedReport!.reportedId;

    final res = await supabase.from("user_report_responses").insert({
      "report_id": _selectedReport!.id,
      "admin_id": me.id,
      "target_user_id": targetId,
      "message": _responseMsg.trim(),
      "action_taken": _actionTaken,
    });

    if (res.error!= null) {
      _showToast("فشل الإرسال", isError: true);
      setState(() => _working = false);
      return;
    }

    if (_actionTaken == "ban" && _responseTarget == "reported") {
      await supabase.from("profiles").update({"is_banned": true}).eq("id", _selectedReport!.reportedId);
    }

    await supabase.from("user_reports").update({
      "status": "resolved",
      "resolved_at": DateTime.now().toIso8601String(),
      "resolved_by": me.id,
      "admin_note": _responseMsg.trim(),
    }).eq("id", _selectedReport!.id);

    _showToast("تم إرسال الرد والإشعار");
    setState(() {
      _responseMsg = "";
      _actionTaken = "none";
      _selectedReport = null;
      _working = false;
    });
    _refresh();
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError? AppColors.destructive : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool> _showConfirm(String msg) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("تأكيد")),
        ],
      ),
    )?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBg),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('لوحة الأدمن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('إدارة الغرف والمستخدمين والبلاغات', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // navigate to settings
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats
                _buildStats(),
                const SizedBox(height: 16),

                // Tabs
                _buildTabs(),
                const SizedBox(height: 16),

                // Content
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        ),
      ),
      // Modal للبلاغ
      bottomSheet: _selectedReport!= null? _buildReportModal() : null,
    );
  }

  Widget _buildStats() {
    final items = [
      {'icon': Icons.people, 'label': 'مستخدمون', 'value': _stats.users},
      {'icon': Icons.layers, 'label': 'غرف', 'value': _stats.rooms},
      {'icon': Icons.message, 'label': 'رسائل اليوم', 'value': _stats.messagesToday},
      {'icon': Icons.schedule, 'label': 'بالانتظار', 'value': _stats.pending, 'hl': _stats.pending > 0},
      {'icon': Icons.flag, 'label': 'بلاغات', 'value': _stats.reports, 'hl': _stats.reports > 0},
    ];

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
      children: items.map((s) {
        final hl = s['hl'] == true;
        return GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'] as IconData, size: 16, color: hl? AppColors.primary : AppColors.mutedForeground),
              const SizedBox(height: 4),
              Text(s['label'] as String, style: const TextStyle(fontSize: 9)),
              Text(_loading? '...' : '${s['value']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      ['pending', 'طلبات (${_stats.pending})'],
      ['rooms', 'الغرف'],
      ['users', 'المستخدمون'],
      ['reports', 'البلاغات (${_stats.reports})'],
    ];

    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((t) {
          final active = _tab == t[0];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = t[0]),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: active? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    t[1],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active? AppColors.primaryForeground : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    switch (_tab) {
      case 'pending':
        return _buildPendingRooms();
      case 'rooms':
        return _buildRooms();
      case 'users':
        return _buildUsers();
      case 'reports':
        return _buildReports();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPendingRooms() {
    if (_pendingRooms.isEmpty) return const Center(child: Text('لا توجد طلبات'));
    return ListView.builder(
      itemCount: _pendingRooms.length,
      itemBuilder: (ctx, i) {
        final r = _pendingRooms[i];
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(r.name[0], style: const TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(r.description?? 'بلا وصف', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRoom(r.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('اعتماد'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success.withOpacity(0.1), foregroundColor: AppColors.success),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectRoom(r.id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('رفض'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive.withOpacity(0.1), foregroundColor: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRooms() { /* نفس النمط */ return const SizedBox(); }
  Widget _buildUsers() { /* نفس النمط */ return const SizedBox(); }
  Widget _buildReports() { /* نفس النمط */ return const SizedBox(); }
  Widget _buildReportModal() { /* Modal كامل */ return const SizedBox(); }
}
