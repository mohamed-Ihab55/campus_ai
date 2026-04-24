import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HeaderOfTable extends StatelessWidget {
  const HeaderOfTable({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
        SizedBox(width: 6),
        Text(
          'College Rules',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
