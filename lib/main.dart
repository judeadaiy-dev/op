import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_settings_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/private_chat_screen.dart';
import 'screens/rooms_screen.dart';
import 'screens/edit_room_screen.dart';
import 'screens/room_members_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/not_found_screen.dart';

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
