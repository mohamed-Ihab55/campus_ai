import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TableCellText extends StatelessWidget {
  final String text;
  const TableCellText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
