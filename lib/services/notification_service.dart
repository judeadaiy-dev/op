import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_client.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // ====================================================================
  // Init
  // ====================================================================
  static Future<void> init() async {
    // 1. طلب صلاحيات iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 2. إعداد الإشعارات المحلية
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 3. إنشاء قناة Android
    await _createNotificationChannel();

    // 4. حفظ FCM Token
    await _saveFCMToken();

    // 5. الاستماع للتحديثات
    _firebaseMessaging.onTokenRefresh.listen(_updateFCMToken);

    // 6. الاستماع للإشعارات في Foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. الاستماع عند الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // ====================================================================
  // FCM Token Management
  // ====================================================================
  static Future<void> _saveFCMToken() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      await supabase.from('user_fcm_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static Future<void> _updateFCMToken(String token) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('user_fcm_tokens').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // ====================================================================
  // Send Push - يستدعي Edge Function
  // ====================================================================
  static Future<void> sendPush({
    required String userId,
    required String title,
    required String body,
    String? link,
    String type = 'system',
  }) async {
    try {
      await supabase.functions.invoke('send-notification', body: {
        'user_id': userId,
        'title': title,
        'body': body,
        'link': link,
        'type': type,
      });
    } catch (e) {
      print('Error sending push: $e');
    }
  }

  // ====================================================================
  // Local Notification - للإشعارات الداخلية
  // ====================================================================
  static Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'إشعارات مهمة',
      channelDescription: 'قناة الإشعارات المهمة',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFB6D6FF),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ====================================================================
  // Handlers
  // ====================================================================
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // اعرض إشعار محلي لما التطبيق مفتوح
    await showLocal(
      title: message.notification?.title?? 'إشعار جديد',
      body: message.notification?.body?? '',
      payload: message.data['link'],
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final link = message.data['link'];
    if (link!= null) {
      // Navigation logic - تحتاج GlobalKey<NavigatorState>
      print('Navigate to: $link');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload!= null) {
      print('Navigate to: $payload');
    }
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات مهمة',
      description: 'قناة الإشعارات المهمة',
      importance: Importance.max,
    );

    await _localNotifications
       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
       ?.createNotificationChannel(androidChannel);
  }

  // ====================================================================
  // Badge Count
  // ====================================================================
  static Future<void> setBadgeCount(int count) async {
    // iOS only
    if (Platform.isIOS) {
      // يحتاج flutter_app_badger
    }
  }
}
