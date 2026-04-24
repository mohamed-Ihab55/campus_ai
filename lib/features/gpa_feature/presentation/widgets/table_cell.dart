import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TableCellElement extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isPrimary;
  final bool isSecondary;

  const TableCellElement(
    this.text, {super.key,
    this.isHeader = false,
    this.isPrimary = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 12 : 12,
          fontWeight: isHeader
              ? FontWeight.w700
              : (isPrimary ? FontWeight.w800 : FontWeight.w500),
          color: isHeader
              ? AppColors.primary
              : isPrimary
                  ? AppColors.primary
                  : isSecondary
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
        ),
      ),
    );
  }
}
