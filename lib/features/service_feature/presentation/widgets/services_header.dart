import 'package:campus_ai/features/home_feature/presentation/widgets/decoration_backgroung_stack_home_screen.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/welcome_section_home_screen.dart';
import 'package:flutter/material.dart';

class ServicesHeader extends StatelessWidget {
  const ServicesHeader(
      {super.key,
      required this.titleName,
      required this.subTitle,
      required this.description});
  final String titleName, subTitle, description;
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
                  WelcomeSectionHomeScreen(
                    tileName: titleName,
                    subTitle: subTitle,
                    description: description,
                  ),
                  // const SearchSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
