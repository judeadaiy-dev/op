import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../screens/chat_list_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _currentIndex = 0;
  bool _isAuthChecked = false;

  final List<Widget> _screens = [
    const ChatListScreen(), // 0: محادثة
    const SearchScreen(), // 1: غرف
    const ProfileScreen(), // 2: حساب
    const SettingsScreen(), // 3: همبرغر
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppSettingsProvider>(
      builder: (context, auth, settings, _) {
        // 1. اذا بعد ما تحقق من التسجيل - اعرض شاشة اللودنق
        if (!auth.loading && !_isAuthChecked) {
          _isAuthChecked = true;
          
          // اذا مو مسجل دخول روح للترحيب
          if (auth.user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/welcome');
            });
          }
        }

        // 2. اذا جاري التحميل او مو مسجل دخول - اعرض شاشة اللودنق
        if (auth.loading || auth.user == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الشعار
                    if (settings.settings?.appLogoUrl.isNotEmpty?? false)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            settings.settings!.appLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_rounded,
                                size: 60,
                                color: AppColors.primaryForeground,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 60,
                          color: AppColors.primaryForeground,
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // اسم التطبيق
                    Text(
                      settings.settings?.appName?? 'SeaChat',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // الوصف
                    Text(
                      'تواصل مع أصدقائك بسهولة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // اللودنق
                    const CircularProgressIndicator(),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 3. اذا مسجل دخول - اعرض الشاشة الرئيسية + البار السفلي العائم
        return Scaffold(
          extendBody: true, // مهم: يخلي المحتوى يمتد تحت البار
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        );
      },
    );
  }
}
