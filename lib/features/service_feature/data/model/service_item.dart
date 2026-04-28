import 'package:flutter/material.dart';

class ServiceItem {
  final String title;
  final String subtitle;
  final Color borderColor;
  final Color accentColor;
  final IconData icon;
  final String route;

  ServiceItem({
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.accentColor,
    required this.icon,
    required this.route,
  });
}
