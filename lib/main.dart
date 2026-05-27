import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// المجلدات الفعلية داخل providers المتواجدة بمستودعك
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/online_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/unread_provider.dart';

// الشاشات الفعلية داخل screens المتواجدة بمستودعك
import 'screens/admin_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_room_screen.dart';
import 'screens/index_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';

// المجلد الداخلي للشاشات screens/auth المتواجد بمستودعك
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: settings.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.dark,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/chat': (context) => const PrivateChatScreen(),
              '/rooms': (context) => const RoomsScreen(),
              '/edit-room': (context) => const EditRoomScreen(),
              '/room-members': (context) => const RoomMembersScreen(),
              '/friends': (context) => const FriendsScreen(),
              '/dashboard': (context) => const UserDashboardScreen(),
              '/privacy': (context) => const PrivacyScreen(),
              '/profile': (context) => const UserProfileScreen(),
              '/admin': (context) => const AdminSettingsScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => const NotFoundScreen(),
            ),
          );
        },
      ),
    );
  }
}
