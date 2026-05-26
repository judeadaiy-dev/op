import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSettingsProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  
  String _appName = 'تطبيق المحادثة';
  String _appLogoUrl = '';
  String _chatBackgroundUrl = '';
  bool _isLoading = true;

  String get appName => _appName;
  String get appLogoUrl => _appLogoUrl;
  String get chatBackgroundUrl => _chatBackgroundUrl;
  bool get isLoading => _isLoading;

  AppSettingsProvider() {
    fetchSettings();
    _listenToChanges();
  }

  Future<void> fetchSettings() async {
    try {
      final response = await supabase
         .from('app_settings')
         .select()
         .eq('id', 1)
         .single();

      _appName = response['app_name']?? 'تطبيق المحادثة';
      _appLogoUrl = response['app_logo_url']?? '';
      _chatBackgroundUrl = response['chat_background_url']?? '';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToChanges() {
    supabase
       .channel('public:app_settings')
       .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'app_settings',
          callback: (payload) {
            fetchSettings();
          },
        )
       .subscribe();
  }

  Future<void> updateSettings({
    String? appName,
    String? appLogoUrl,
    String? chatBackgroundUrl,
  }) async {
    await supabase.from('app_settings').update({
      if (appName!= null) 'app_name': appName,
      if (appLogoUrl!= null) 'app_logo_url': appLogoUrl,
      if (chatBackgroundUrl!= null) 'chat_background_url': chatBackgroundUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', 1);
  }
}
