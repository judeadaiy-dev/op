import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Profile? _profile;
  bool _loading = true;
  bool _isAdmin = false;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get loading => _loading;
  bool get isAdmin => _isAdmin;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    supabase.auth.onAuthStateChange.listen((data) async {
      _user = data.session?.user;
      if (_user != null) {
        await _loadProfile();
        await _checkAdmin();
      } else {
        _profile = null;
        _isAdmin = false;
      }
      _loading = false;
      notifyListeners();
    });

    // Check initial session
    final session = supabase.auth.currentSession;
    if (session != null) {
      _user = session.user;
      await _loadProfile();
      await _checkAdmin();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      final res = await supabase
          .from('profiles')
          .select('*')
          .eq('id', _user!.id)
          .single();
      _profile = Profile.fromJson(res);
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _checkAdmin() async {
    if (_user == null) return;
    try {
      final res = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', _user!.id)
          .eq('role', 'admin')
          .maybeSingle();
      _isAdmin = res != null;
      notifyListeners();
    } catch (e) {
      _isAdmin = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': displayName ?? username,
        },
      );
      if (res.user == null) throw Exception('فشل إنشاء الحساب');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) throw Exception('فشل تسجيل الدخول');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.drdshati.app://login-callback',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    _profile = null;
    _isAdmin = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_user == null) return;
    try {
      await supabase.from('profiles').update({
        if (username != null) 'username': username,
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _user!.id);
      await _loadProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;
    try {
      // احذف البروفايل والبيانات المرتبطة
      await supabase.from('profiles').delete().eq('id', _user!.id);
      // احذف المستخدم من auth - يتطلب Edge Function
      await supabase.functions.invoke('delete-user');
      await signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
