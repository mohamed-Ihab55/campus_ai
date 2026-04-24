

import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:campus_ai/core/utils/gpa_action_buttons.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/college_rules_card.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/formula_card.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/result_card.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/semester_row.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:flutter/material.dart';

class CumulativeTab extends StatelessWidget {
  final List<SemesterEntry> semesters;
  final double? result;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int, SemesterEntry) onSemesterChanged;
  final VoidCallback onCalculate;
  final VoidCallback onReset;

  const CumulativeTab({
    super.key,
    required this.semesters,
    required this.result,
    required this.onAdd,
    required this.onRemove,
    required this.onSemesterChanged,
    required this.onCalculate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
            child: FormulaCard(
          formulaEn: 'Cumulative GPA = Σ(Sem.GPA × Hours) ÷ Σ All Hours',
        )),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => SemesterRow(
                index: i,
                entry: semesters[i],
                onRemove: () => onRemove(i),
                onChanged: (s) => onSemesterChanged(i, s),
              ),
              childCount: semesters.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
                text: 'Add Semester',
                textColor: AppColors.primary,
                backgroundColor:
                    AppColors.textSecondary.withValues(alpha: 0.15),
                onTap: onAdd),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        GpaActionButtons(onCalculate: onCalculate, onReset: onReset),

        if (result != null)
          SliverToBoxAdapter(
            child: ResultCard(gpa: result!, isSemester: false),
          ),

        const SliverToBoxAdapter(child: CollegeRulesCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
