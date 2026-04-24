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

  final List<Widget> _screens = [
    const HomeScreen(),
    const FaqScreen(),
    const MapScreen(),
    const ChatBotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
