import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSettings {
  // الأسماء الصحيحة اللي تطابق الشاشات
  final String name;
  final String logo;
  final bool maintenanceMode;
  final String version;
  final String welcomeMessage;
  final bool allowRegistration;

  AppSettings({
    required this.name,
    required this.logo,
    required this.maintenanceMode,
    required this.version,
    required this.welcomeMessage,
    required this.allowRegistration,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      name: json['name']?? 'SeaChat',
      logo: json['logo']?? '',
      maintenanceMode: json['maintenance_mode']?? false,
      version: json['version']?? '1.0.0',
      welcomeMessage: json['welcome_message']?? 'مرحبا بك في التطبيق',
      allowRegistration: json['allow_registration']?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'maintenance_mode': maintenanceMode,
      'version': version,
      'welcome_message': welcomeMessage,
      'allow_registration': allowRegistration,
    };
  }
}

class AppSettingsProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  AppSettings? settings; // المتغير اسمه settings
  bool isLoading = false;

  // الدالة اسمها loadSettings
  Future<void> loadSettings() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
        .from('app_settings')
        .select()
        .limit(1)
        .single();

      settings = AppSettings.fromJson(response);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      // قيم افتراضية اذا ما لقى الجدول
      settings = AppSettings(
        name: 'SeaChat',
        logo: '',
        maintenanceMode: false,
        version: '1.0.0',
        welcomeMessage: 'مرحبا بك في SeaChat',
        allowRegistration: true,
      );
      isLoading = false;
      notifyListeners();
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await supabase.from('app_settings').upsert(newSettings.toJson());
      settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }
}
