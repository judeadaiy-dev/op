import 'package:flutter/material.dart';

class AppTheme {
  // --radius = 12px افتراضي shadcn
  static const double radius = 12.0;
  
  // الوان CSS vars لازم تعرفها من globals.css
  // مؤقتاً حطيت قيم shadcn الافتراضية. ارسل لي globals.css عشان اطابقها 100%
  static const Color _primary = Color(0xFF0F172A);
  static const Color _primaryForeground = Color(0xFFF8FAFC);
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _foreground = Color(0xFF020817);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _muted = Color(0xFFF1F5F9);
  static const Color _accent = Color(0xFFF1F5F9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'ReadexPro', // sans: Readex Pro أولاً
    
    // container: center, padding: 1rem
    visualDensity: VisualDensity.adaptivePlatformDensity,
    
    colorScheme: const ColorScheme.light(
      primary: _primary,
      onPrimary: _primaryForeground,
      secondary: _muted,
      surface: _background,
      onSurface: _foreground,
      outline: _border,
    ),
    
    // borderRadius: lg, md, sm
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius), // lg
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius - 4), // md
        borderSide: const BorderSide(color: _border),
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Tajawal'), // display font
      displayMedium: TextStyle(fontFamily: 'Tajawal'),
      bodyLarge: TextStyle(fontFamily: 'ReadexPro'), // sans font
      bodyMedium: TextStyle(fontFamily: 'ReadexPro'),
    ),
  );

  // darkMode: ["class"] 
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'ReadexPro',
    brightness: Brightness.dark,
  );
}
