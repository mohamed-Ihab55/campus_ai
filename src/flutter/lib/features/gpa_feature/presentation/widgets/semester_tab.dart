
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:campus_ai/core/utils/gpa_action_buttons.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/formula_card.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/gpa_course_row.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/grade_table.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/result_card.dart';
import 'package:campus_ai/features/service_feature/data/model/gpa_course_model.dart';
import 'package:flutter/material.dart';

class SemesterTab extends StatelessWidget {
  final List<GpaCourse> courses;
  final double? result;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int, GpaCourse) onCourseChanged;
  final VoidCallback onCalculate;
  final VoidCallback onReset;

  const SemesterTab({
    super.key,
    required this.courses,
    required this.result,
    required this.onAdd,
    required this.onRemove,
    required this.onCourseChanged,
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
          formulaEn: 'Semester GPA = Σ(Points × Hours) ÷ Σ Hours',
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => GpaCourseRow(
                index: i,
                course: courses[i],
                onRemove: () => onRemove(i),
                onChanged: (c) => onCourseChanged(i, c),
              ),
              childCount: courses.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
                text: 'Add Course',
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
            child: ResultCard(gpa: result!, isSemester: true),
          ),

        const SliverToBoxAdapter(child: GradeTable()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
