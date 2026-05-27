import 'package:chat_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppSettingsProvider>(
      builder: (context, auth, settings, _) {
        // اذا مسجل دخول روح للمحادثات
        if (auth.user!= null && !auth.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/chat');
          });
        }

        // اذا مو مسجل روح للترحيب
        if (auth.user == null && !auth.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
        }

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
                  if (settings.settings.appLogoUrl.isNotEmpty)
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
                          settings.settings.appLogoUrl,
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
                    settings.settings.appName,
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
      },
    );
  }
}
