import 'package:flutter/material.dart';

/// نوع تراکنش
enum TransactionType { income, expense }

/// مدل ساده برای نمایش هر دسته‌بندی همراه با آیکون
class CategoryItem {
  final String name;
  final IconData icon;

  const CategoryItem({required this.name, required this.icon});
}

/// لیست دسته‌بندی‌های ثابت برنامه
class AppCategories {
  AppCategories._();

  static const List<CategoryItem> incomeCategories = [
    CategoryItem(name: 'حقوق', icon: Icons.work_outline_rounded),
    CategoryItem(name: 'فروش', icon: Icons.storefront_outlined),
    CategoryItem(name: 'هدیه', icon: Icons.card_giftcard_rounded),
    CategoryItem(name: 'سرمایه‌گذاری', icon: Icons.trending_up_rounded),
    CategoryItem(name: 'سایر', icon: Icons.more_horiz_rounded),
  ];

  static const List<CategoryItem> expenseCategories = [
    CategoryItem(name: 'غذا', icon: Icons.restaurant_outlined),
    CategoryItem(name: 'حمل‌ونقل', icon: Icons.directions_car_outlined),
    CategoryItem(name: 'قبوض', icon: Icons.receipt_long_outlined),
    CategoryItem(name: 'خرید', icon: Icons.shopping_bag_outlined),
    CategoryItem(name: 'درمان', icon: Icons.local_hospital_outlined),
    CategoryItem(name: 'تفریح', icon: Icons.sports_esports_outlined),
    CategoryItem(name: 'سایر', icon: Icons.more_horiz_rounded),
  ];

  /// گرفتن لیست دسته‌بندی بر اساس نوع تراکنش
  static List<CategoryItem> byType(TransactionType type) {
    return type == TransactionType.income ? incomeCategories : expenseCategories;
  }

  /// پیدا کردن آیکون یک دسته‌بندی بر اساس نام (برای نمایش در لیست تراکنش‌ها)
  static IconData iconForCategory(String name, TransactionType type) {
    final list = byType(type);
    final match = list.where((c) => c.name == name);
    if (match.isNotEmpty) return match.first.icon;
    return Icons.category_outlined;
  }
}
