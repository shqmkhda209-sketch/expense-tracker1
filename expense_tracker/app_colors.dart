import 'package:flutter/material.dart';

/// پالت رنگی اصلی برنامه بر اساس رنگ سبز (#22C55E)
class AppColors {
  AppColors._();

  // رنگ اصلی برند
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF86EFAC);

  // رنگ‌های معنایی
  static const Color income = Color(0xFF22C55E); // سبز برای درآمد
  static const Color incomeLight = Color(0xFFDCFCE7);
  static const Color expense = Color(0xFFEF4444); // قرمز برای هزینه
  static const Color expenseLight = Color(0xFFFEE2E2);

  // حالت روشن
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // حالت تیره
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // رنگ‌های کمکی برای نمودارها
  static const List<Color> chartColors = [
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF64748B),
  ];
}
