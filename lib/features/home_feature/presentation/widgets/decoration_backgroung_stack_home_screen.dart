import 'package:campus_ai/features/home_feature/presentation/widgets/dots_grid.dart';
import 'package:flutter/material.dart';

class DecorationBackgroungStackHomeScreen extends StatelessWidget {
  const DecorationBackgroungStackHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),
        ),
        // decorative circle bottom-right
        Positioned(
          bottom: -60,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // ring
        Positioned(
          bottom: 20,
          left: 40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
          ),
        ),
        // dots grid
        const Positioned(
          top: 80,
          right: 28,
          child: DotsGrid(),
        ),
      ],
    );
  }
}
