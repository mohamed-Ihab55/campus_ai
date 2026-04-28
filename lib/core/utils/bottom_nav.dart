import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final PageController? controller;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.controller,
  });

  void _handleTap(int index) {
    onTap(index);

    controller?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bgColor,
      currentIndex: currentIndex,
      onTap: _handleTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      elevation: 8,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy),
          label: 'AI Guide',
        ),
      ],
    );
  }
}
