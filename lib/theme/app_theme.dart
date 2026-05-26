import 'package:flutter/material.dart';

// ====================================================================
// App Colors - نفس ألوان التالويند glass
// ====================================================================
class AppColors {
  // Primary
  static const Color primary = Color(0xFFB6D6FF);
  static const Color primaryForeground = Color(0xFF1A1821);
  
  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F0F12);
  
  // Foreground
  static const Color foreground = Color(0xFF1A1821);
  static const Color darkForeground = Color(0xFFEDEDED);
  
  // Card
  static const Color card = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1A1821);
  
  // Glass
  static Color get glass => const Color(0xFFFFFFFF).withOpacity(0.7);
  static Color get darkGlass => const Color(0xFF1A1821).withOpacity(0.7);
  static Color get glassThick => const Color(0xFFFFFFFF).withOpacity(0.85);
  static Color get darkGlassThick => const Color(0xFF1A1821).withOpacity(0.85);
  static Color get glassBorder => const Color(0xFFFFFFFF).withOpacity(0.2);
  static Color get darkGlassBorder => const Color(0xFFFFFFFF).withOpacity(0.1);
  
  // Muted
  static const Color muted = Color(0xFFF4F4F5);
  static const Color darkMuted = Color(0xFF27272A);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color darkMutedForeground = Color(0xFFA1A1AA);
  
  // Border
  static const Color border = Color(0xFFE4E4E7);
  static const Color darkBorder = Color(0xFF27272A);
  
  // Success / Destructive
  static const Color success = Color(0xFF22C55E);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
}

// ====================================================================
// App Theme - Light + Dark
// ====================================================================
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.muted,
        onSecondary: AppColors.foreground,
        surface: AppColors.card,
        onSurface: AppColors.foreground,
        background: AppColors.background,
        onBackground: AppColors.foreground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        outline: AppColors.border,
        surfaceVariant: AppColors.muted,
        onSurfaceVariant: AppColors.mutedForeground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassThick,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        titleTextStyle: const TextStyle(
          color: AppColors.foreground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.glassThick,
        elevation: 0,
        selectedItemColor: AppColors.foreground,
        unselectedItemColor: AppColors.mutedForeground,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.glassThick,
        elevation: 0,
        indicatorColor: Colors.white.withOpacity(0.55),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.glassThick,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.glassThick,
        contentTextStyle: const TextStyle(color: AppColors.foreground, fontFamily: 'Cairo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.darkMuted,
        onSecondary: AppColors.darkForeground,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkForeground,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        outline: AppColors.darkBorder,
        surfaceVariant: AppColors.darkMuted,
        onSurfaceVariant: AppColors.darkMutedForeground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkGlassThick,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkForeground),
        titleTextStyle: const TextStyle(
          color: AppColors.darkForeground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGlassThick,
        elevation: 0,
        selectedItemColor: AppColors.darkForeground,
        unselectedItemColor: AppColors.darkMutedForeground,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkGlassThick,
        elevation: 0,
        indicatorColor: Colors.white.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGlassThick,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGlassThick,
        contentTextStyle: const TextStyle(color: AppColors.darkForeground, fontFamily: 'Cairo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
