import 'package:campus_ai/features/home_feature/presentation/widgets/custom_home_app_bar.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/decoration_backgroung_stack_home_screen.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/search_section.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/welcome_section_home_screen.dart';
import 'package:flutter/material.dart';

class WelcomeAndSearchSection extends StatelessWidget {
  final Animation<double> blinkAnim;
  const WelcomeAndSearchSection({super.key, required this.blinkAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF1B4FCC), Color(0xFF1338A8), Color(0xFF0D2680)],
        ),
      ),
      child: Stack(
        children: [
          const DecorationBackgroungStackHomeScreen(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHomeAppBar(blinkAnim: blinkAnim),
                  const SizedBox(height: 20),
                  const WelcomeSectionHomeScreen(
                    tileName: 'Campus Guide',
                    subTitle: 'Sciences',
                    description:
                        'University of Ain Shams — Everything you need in one place',
                  ),
                  const SizedBox(height: 18),
                  const SearchSection(
                    fillColor: Colors.transparent,
                    hintText: 'Search for places, services...',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
