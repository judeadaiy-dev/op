import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class EditRoomScreen extends StatefulWidget {
  final String roomId;
  const EditRoomScreen({super.key, required this.roomId});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  Map<String, dynamic>? _room;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _coverUrl = '';
  bool _loading = true;
  bool _uploading = false;
  bool _saving = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    final res = await supabase.from('rooms').select('*').eq('id', widget.roomId).maybeSingle();
    if (res!= null) {
      setState(() {
        _room = res;
        _nameCtrl.text = res['name'];
        _descCtrl.text = res['description']?? '';
        _coverUrl = res['cover_url']?? '';
        _loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 85);
    if (file == null || supabase.auth.currentUser == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final path = '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('room-covers').uploadBinary(path, bytes);
      final url = supabase.storage.from('room-covers').getPublicUrl(path);
      setState(() => _coverUrl = url);
      _showToast('تم رفع الصورة');
    } catch (e) {
      _showToast('فشل رفع الصورة', isError: true);
    }
    setState(() => _uploading = false);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showToast('اسم الغرفة مطلوب', isError: true);
      return;
    }
    setState(() => _saving = true);
    final res = await supabase.from('rooms').update({
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'cover_url': _coverUrl.isEmpty? null : _coverUrl,
    }).eq('id', widget.roomId);

    setState(() => _saving = false);
    if (res.error!= null) {
      _showToast('فشل الحفظ', isError: true);
    } else {
      _showToast('تم حفظ التعديلات');
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الغرفة؟'),
        content: const Text('سيتم حذف كل الرسائل ولا يمكن التراجع'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm!= true) return;

    await supabase.from('rooms').delete().eq('id', widget.roomId);
    _showToast('حُذفت الغرفة');
    Navigator.pushReplacementNamed(context, '/rooms');
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError? AppColors.destructive : AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_room == null) return const Scaffold(body: Center(child: Text('الغرفة غير موجودة')));
    if (_room!['owner_id']!= supabase.auth.currentUser?.id) {
      return const Scaffold(body: Center(child: Text('لا تملك صلاحية تعديل هذه الغرفة', style: TextStyle(color: Colors.red))));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBg),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                    style: IconButton.styleFrom(backgroundColor: AppColors.glassThick),
                  ),
                  const SizedBox(width: 12),
                  const Text('تعديل الغرفة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // صورة الغلاف
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: _coverUrl.isNotEmpty? DecorationImage(image: NetworkImage(_coverUrl), fit: BoxFit.cover) : null,
                      gradient: _coverUrl.isEmpty? LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.05)]) : null,
                    ),
                    child: _coverUrl.isEmpty? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: AppColors.mutedForeground),
                          const Text('لا توجد صورة بعد', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ) : null,
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _uploading? null : _pickImage,
                        icon: _uploading? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt, size: 18),
                        label: Text(_uploading? "جارٍ الرفع..." : _coverUrl.isEmpty? "رفع من الاستوديو" : "تغيير الصورة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.glassThick,
                          foregroundColor: AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // اسم الغرفة
              const Text('اسم الغرفة', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'مثال: غرفة الأصدقاء',
                  filled: true,
                  fillColor: AppColors.glass,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // النبذة
              const Text('نبذة عن الغرفة', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLength: 200,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب وصفاً مختصراً...',
                  filled: true,
                  fillColor: AppColors.glass,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving? null : _save,
                      icon: _saving? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save, size: 18),
                      label: const Text('حفظ'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.foreground,
                        foregroundColor: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('حذف الغرفة'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.destructive.withOpacity(0.1),
                        foregroundColor: AppColors.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
