import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30), // يرفعه من الأسفل
      child: Center(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), // رمادي غامق
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(0, Icons.chat_bubble_rounded, currentIndex == 0),
              _buildNavItem(1, Icons.hub_rounded, currentIndex == 1), // غرف
              _buildNavItem(2, Icons.person_rounded, currentIndex == 2),
              _buildNavItem(3, Icons.menu_rounded, currentIndex == 3), // همبرغر
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected 
           ? const Color(0xFF3A3A3C) // لون التحديد
            : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          color: isSelected? Colors.white : Colors.grey[400],
          size: 22, // حجم صغير مثل الصورة
        ),
      ),
    );
  }
}
