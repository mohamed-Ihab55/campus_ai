import 'dart:async';
import 'package:campus_ai/features/home_feature/presentation/widgets/custom_home_app_bar.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/decoration_backgroung_stack_home_screen.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/welcome_section_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication_feature/data/cubit/auth_cubit.dart';

class HomeAppBar extends StatefulWidget {
  final Animation<double> blinkAnim;

  const HomeAppBar({super.key, required this.blinkAnim});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  Timer? _debounce;


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
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
          const DecorationBackgroundStackHomeScreen(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocProvider(
                    create: (_) => AuthCubit(),
                    child: CustomHomeAppBar(
                      blinkAnim: widget.blinkAnim,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const WelcomeSectionHomeScreen(
                    tileName: 'Campus Guide',
                    subTitle: 'Sciences',
                    description:
                    'University of Ain Shams — Everything you need in one place',
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
