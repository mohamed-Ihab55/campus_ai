import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ServiceTabBar extends StatelessWidget {
  final TabController controller;
  const ServiceTabBar({super.key, required this.controller, required this.tab1, required this.tab2});
final String tab1,tab2;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: TabBar(
        controller: controller,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs:  [
          Tab(text: tab1),
          Tab(text: tab2),
        ],
      ),
    );
  }
}
