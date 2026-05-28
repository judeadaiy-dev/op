import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/providers/online_provider.dart';
import 'package:chat_app/providers/app_settings_provider.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:chat_app/screens/index_screen.dart';
import 'package:chat_app/screens/welcome_screen.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:chat_app/screens/chat_room_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:chat_app/screens/admin_screen.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:chat_app/screens/notifications_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT.supabase.co', // حط رابط مشروعك
    anonKey: 'YOUR_ANON_KEY', // حط المفتاح مالك
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnlineProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()..loadSettings()),
      ],
      child: MaterialApp(
        title: 'SeaChat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const IndexScreen(), // الشاشة الرئيسية مع البار السفلي
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/chats': (context) => const ChatListScreen(),
          '/chat': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            if (args == null || args['roomId'] == null) {
              return const Scaffold(
                body: Center(child: Text('خطأ: معرف الغرفة مفقود')),
              );
            }
            return ChatRoomScreen(roomId: args['roomId']);
          },
          '/profile': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return ProfileScreen(userId: args?['userId']);
          },
          '/settings': (context) => const SettingsScreen(),
          '/admin': (context) => const AdminScreen(),
          '/search': (context) => const SearchScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('خطأ')),
              body: const Center(
                child: Text('الصفحة غير موجودة'),
              ),
            ),
          );
        },
      ),
    );
  }
}
