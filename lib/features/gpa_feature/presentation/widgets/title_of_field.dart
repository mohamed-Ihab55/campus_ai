import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TitleOfField extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;

  const TitleOfField({super.key,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Semester ${index + 1}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.red.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.red,
            ),
          ),
        ),
      ],
    );
  }
}
