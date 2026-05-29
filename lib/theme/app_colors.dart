import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - بنفسجي
  static const Color primary = Color(0xFF824C97); // البنفسجي الرئيسي
  static const Color primaryForeground = Color(0xFFFFFFFF); // نص ابيض داخل البنفسجي
  static const Color secondary = Color(0xFF6A3A7E); // بنفسجي اغمق للكحلي
  static const Color accent = Color(0xFF9D6BAD); // بنفسجي فاتح
  
  // الخلفيات - نهاري
  static const Color background = Color(0xFFFFFFFF); // ابيض صافي
  static const Color card = Color(0xFFFFFFFF); // ابيض
  
  // الخلفيات - ليلي
  static const Color backgroundDark = Color(0xFF3F3F3F); // رمادي غامق #3f3f3f
  static const Color cardDark = Color(0xFF4A4A4A); // رمادي افتح شوي
  
  // النصوص - نهاري
  static const Color textPrimary = Color(0xFF000000); // اسود للعناوين
  static const Color textSecondary = Color(0xFF424242); // رمادي غامق للنصوص الثانوية
  static const Color textLight = Color(0xFFFFFFFF); // ابيض
  
  // النصوص - ليلي
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // ابيض
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // رمادي فاتح
  
  // الأيقونات
  static const Color iconLight = Color(0xFF000000); // اسود للنهاري
  static const Color iconDark = Color(0xFFFFFFFF); // ابيض لليلي
  
  // الحالات
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // التدرجات - بنفسجي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF824C97), Color(0xFF9D6BAD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // لون الكحلي للأزرار بالليلي
  static const Color darkButton = Color(0xFF2C2C3E); // كحلي غامق
}
