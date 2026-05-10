import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/view/chat_bot_screen.dart';
import 'package:campus_ai/features/home_feature/presentation/view/home_screen.dart';
import 'package:campus_ai/features/map_feature/presentation/view/map_screen.dart';
import 'package:campus_ai/features/service_feature/presentation/view/faq_and_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FaqScreen(),
    MapScreen(),
    ChatBotScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(FontAwesomeIcons.house, "Home"),
    _NavItem(FontAwesomeIcons.gear, "Services"),
    _NavItem(FontAwesomeIcons.earthAfrica, "Map"),
    _NavItem(FontAwesomeIcons.openai, "D3bs"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
                  (index) {
                final isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutExpo,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 18 : 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      )
                          : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: isSelected ? 1.15 : 1,
                          child: FaIcon(
                            _items[index].icon,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isSelected
                              ? Padding(
                            padding:
                            const EdgeInsets.only(left: 8),
                            child: Text(
                              _items[index].label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final FaIconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}