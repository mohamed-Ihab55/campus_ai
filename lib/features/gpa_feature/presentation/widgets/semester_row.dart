import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/inputs_row.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/title_of_field.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:flutter/material.dart';

class SemesterRow extends StatelessWidget {
  final int index;
  final SemesterEntry entry;
  final VoidCallback onRemove;
  final ValueChanged<SemesterEntry> onChanged;

  const SemesterRow({
    super.key,
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleOfField(index: index, onRemove: onRemove),
          const SizedBox(height: 8),
          InputsRow(
            entry: entry,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
