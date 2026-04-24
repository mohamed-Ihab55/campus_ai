import 'package:flutter/material.dart';

class ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback? onTap; // ← السطر الجديد الوحيد

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.accentColor,
    this.onTap, // اختياري — الكاردات القديمة مش محتاجة تحدده
  });
}
