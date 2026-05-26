import 'package:flutter/material.dart';

class AppColors {
  // Light Mode - من :root
  static const appBg = Color(0xFFB6D6FF); // #B6D6FF
  static const appIcon = Color(0xFF1A1821); // #1A1821
  static const appBtn = Color(0xFF5F9EF4); // #5F9EF4
  
  static const background = Color.fromARGB(255, 182, 214, 255); // hsl(212 100% 86%)
  static const foreground = Color.fromARGB(255, 26, 24, 33);    // hsl(252 12% 11%)
  static const card = Color(0xFFFFFFFF);                        // hsl(0 0% 100%)
  static const cardForeground = Color.fromARGB(255, 26, 24, 33); // hsl(252 12% 11%)
  
  static const primary = Color.fromARGB(255, 198, 208, 236);    // hsl(226 56% 84%)
  static const primaryForeground = Color.fromARGB(255, 31, 26, 46); // hsl(252 20% 15%)
  static const primaryDeep = Color.fromARGB(255, 182, 214, 255); // hsl(212 100% 86%)
  
  static const admin = Color.fromARGB(255, 95, 158, 244);       // hsl(214 87% 66%)
  static const adminForeground = Color(0xFFFFFFFF);
  static const adminDeep = Color.fromARGB(255, 45, 125, 250);   // hsl(220 90% 55%)
  
  static const secondary = Color.fromARGB(255, 240, 248, 255);  // hsl(207 100% 97%)
  static const muted = Color.fromARGB(255, 236, 244, 255);      // hsl(212 100% 93%)
  static const mutedForeground = Color.fromARGB(255, 46, 71, 107); // hsl(226 35% 28%)
  
  static const destructive = Color.fromARGB(255, 214, 64, 64);   // hsl(0 70% 55%)
  static const success = Color.fromARGB(255, 33, 195, 99);      // hsl(142 71% 45%)
  static const warning = Color.fromARGB(255, 245, 158, 11);     // hsl(38 92% 50%)
  static const live = Color.fromARGB(255, 255, 51, 77);         // hsl(354 100% 60%)
  
  static const border = Color.fromARGB(255, 255, 233, 138);     // hsl(56 100% 77%)
  static const input = Color.fromARGB(255, 214, 234, 255);      // hsl(212 100% 92%)
  static const ring = Color.fromARGB(255, 142, 161, 214);       // hsl(226 56% 70%)
  
  // radius: 1.5rem = 24px
  static const double radius = 24.0;
  
  // Glass effect
  static const glass = Color.fromARGB(107, 255, 255, 255);       // 0 0% 100% / 0.42
  static const glassThick = Color.fromARGB(148, 255, 255, 255); // 0 0% 100% / 0.58
  static const glassSoft = Color.fromARGB(71, 255, 255, 255);   // 0 0% 100% / 0.28
  static const glassBorder = Color.fromARGB(166, 255, 233, 138); // 56 100% 77% / 0.65
  
  // Gradients
  static const gradientBg = LinearGradient(
    begin: Alignment(-0.9, -1.0),
    end: Alignment(0.9, 1.0),
    colors: [
      Color.fromARGB(255, 182, 214, 255), // 212 100% 86%
      Color.fromARGB(255, 236, 244, 255), // 212 100% 93%
      Color.fromARGB(255, 255, 251, 214), // 56 100% 93%
    ],
    stops: [0.0, 0.52, 1.0],
  );
  
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 182, 214, 255), // 212 100% 86%
      Color.fromARGB(255, 198, 208, 236), // 226 56% 84%
    ],
  );

  // Dark Mode - من .dark
  static const darkBackground = Color.fromARGB(255, 10, 14, 26);   // hsl(225 42% 4%)
  static const darkForeground = Color.fromARGB(255, 248, 250, 252); // hsl(210 40% 98%)
  static const darkCard = Color.fromARGB(255, 17, 21, 35);         // hsl(228 34% 8%)
  static const darkBorder = Color.fromARGB(255, 36, 43, 66);       // hsl(222 30% 20%)
  static const darkMuted = Color.fromARGB(255, 25, 30, 46);        // hsl(222 30% 14%)
  static const darkPrimaryDeep = Color.fromARGB(255, 30, 41, 84);   // hsl(224 64% 20%)
}
