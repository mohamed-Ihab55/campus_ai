
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/data/models/rule_model.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/header_of_table.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/rule_item.dart';
import 'package:flutter/material.dart';

class CollegeRulesCard extends StatelessWidget {
  const CollegeRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderOfTable(),
          const SizedBox(height: 12),
          ..._rules.map((rule) => RuleItem(rule: rule)),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    );
  }
}

const List<RuleModel> _rules = [
  RuleModel(
    emoji: '🎓',
    title: 'Min. to Graduate',
    detail: 'GPA ≥ 2.00 out of 4.00',
  ),
  RuleModel(
    emoji: '🏆',
    title: 'Honor Roll',
    detail: 'GPA ≥ 3.60 — with extra conditions',
  ),
  RuleModel(
    emoji: '📚',
    title: 'Single Major',
    detail: '134 credit hours',
  ),
  RuleModel(
    emoji: '📚',
    title: 'Double Major',
    detail: '140 credit hours',
  ),
  RuleModel(
    emoji: '☀️',
    title: 'Summer Semester',
    detail: 'Max 6 credit hours — optional',
  ),
  RuleModel(
    emoji: '🔄',
    title: 'Re-registration',
    detail: 'Last grade counts only',
  ),
];
