import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          icon: FaIcon(FontAwesomeIcons.house),
          activeIcon: FaIcon(FontAwesomeIcons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.gear),
          activeIcon: FaIcon(FontAwesomeIcons.gear),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.earthAfrica),
          activeIcon: FaIcon(FontAwesomeIcons.earthAfrica),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.openai),
          activeIcon: FaIcon(FontAwesomeIcons.openai),
          label: 'D3bs',
        ),
      ],
    );
  }
}
