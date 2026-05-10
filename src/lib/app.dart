import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/bottom_nav.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/view/chat_bot_screen.dart';
import 'package:campus_ai/features/home_feature/presentation/view/home_screen.dart';
import 'package:campus_ai/features/map_feature/presentation/view/map_screen.dart';
import 'package:campus_ai/features/service_feature/presentation/view/faq_and_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final PageController _controller = PageController();

  final List<Widget> _screens = const [
    HomeScreen(),
    FaqScreen(),
    MapScreen(),
    ChatBotScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);

    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,

      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
