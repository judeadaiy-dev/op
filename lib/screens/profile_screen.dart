import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import '../utils/supabase_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _updating = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    try {
      final res = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      setState(() {
        _profile = res;
        _usernameController.text = res['username']?? '';
        _loading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image!= null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _updateProfile() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    setState(() => _updating = true);

    try {
      String? avatarUrl = _profile?['avatar_url'];

      // ارفع الصورة اذا اختار جديدة
      if (_selectedImage!= null) {
        final fileName = 'avatar_$userId.jpg';
        final path = 'avatars/$fileName';

        await supabase.storage
            .from('avatars')
            .upload(path, _selectedImage!, fileOptions: const FileOptions(upsert: true));

        avatarUrl = supabase.storage.from('avatars').getPublicUrl(path);
      }

      // حدث البروفايل
      await supabase.from('profiles').update({
        'username': _usernameController.text.trim(),
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProfile();
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // الصورة الشخصية
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage!= null
                            ? FileImage(_selectedImage!)
                            : (_profile?['avatar_url']!= null
                                ? NetworkImage(_profile!['avatar_url'])
                                : null) as ImageProvider?,
                        child: _selectedImage == null && _profile?['avatar_url'] == null
                            ? const Icon(Icons.person_rounded, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // اسم المستخدم
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // الإيميل - للعرض فقط
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'البريد الإلكتروني',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                context.read<AuthProvider>().user?.email?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _updating? null : _updateProfile,
                      child: _updating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('حفظ التغييرات'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر تسجيل الخروج
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // معلومات إضافية
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'تاريخ الانضمام',
                          _formatDate(_profile?['created_at']),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'آخر تحديث',
                          _formatDate(_profile?['updated_at']),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير متوفر';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'غير متوفر';
    }
  }
}
