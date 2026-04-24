import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FeatureLabel extends StatelessWidget {
  final String label;
  const FeatureLabel({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
