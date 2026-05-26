import 'package:flutter/material.dart';
import '../utils/supabase_client.dart';

class AppSettings {
  final String appName;
  final String appLogoUrl;
  final String? chatBackgroundUrl;
  final bool maintenanceMode;

  AppSettings({
    required this.appName,
    required this.appLogoUrl,
    this.chatBackgroundUrl,
    required this.maintenanceMode,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      appName: 'دردشاتي',
      appLogoUrl: '',
      chatBackgroundUrl: null,
      maintenanceMode: false,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appName: json['app_name'] ?? 'دردشاتي',
      appLogoUrl: json['app_logo_url'] ?? '',
      chatBackgroundUrl: json['chat_background_url'],
      maintenanceMode: json['maintenance_mode'] ?? false,
    );
  }
}

class AppSettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings.defaultSettings();
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get loading => _loading;

  AppSettingsProvider() {
    _loadSettings();
    _listenRealtime();
  }

  Future<void> _loadSettings() async {
    try {
      final res = await supabase
          .from('app_settings')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (res != null) {
        _settings = AppSettings.fromJson(res);
      }
    } catch (e) {
      print('Error loading app settings: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _listenRealtime() {
    supabase
        .channel('app_settings')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'app_settings',
          filter: PostgresChangeFilter(
            type: 'eq',
            column: 'id',
            value: 1,
          ),
          callback: (payload) {
            _settings = AppSettings.fromJson(payload.newRecord);
            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> updateSettings({
    String? appName,
    String? appLogoUrl,
    String? chatBackgroundUrl,
    bool? maintenanceMode,
  }) async {
    try {
      await supabase.from('app_settings').upsert({
        'id': 1,
        if (appName != null) 'app_name': appName,
        if (appLogoUrl != null) 'app_logo_url': appLogoUrl,
        if (chatBackgroundUrl != null) 'chat_background_url': chatBackgroundUrl,
        if (maintenanceMode != null) 'maintenance_mode': maintenanceMode,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
