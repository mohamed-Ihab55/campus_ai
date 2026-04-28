import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/academic_warning_feature/presentation/widgets/warning_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';

class AcademicWarningScreen extends StatelessWidget {
  const AcademicWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          ServicesHeader(
            height: 255,
            titleName: 'Academic',
            subTitle: 'Warning',
            description:
                'Important information about academic warning policies and procedures.',
          ),
          SizedBox(height: 16),

          WarningItem(
            text:
                "If a student (excluding the first semester) has a cumulative GPA below 2.00 (out of 4.0), they will be placed under academic warning in the following semester (First Warning).",
          ),

          WarningItem(
            text:
                "The student must raise their cumulative GPA to 2.00 or higher within a maximum of four consecutive semesters.",
          ),

          WarningItem(
            text:
                "If the student completes two semesters without reaching the required GPA, a Second Warning will be issued and the guardian will be notified.",
          ),

          WarningItem(
            text:
                "If the student fails to achieve a cumulative GPA of at least 2.00 after four semesters, they will be permanently dismissed from the college.",
          ),

          WarningItem(
            text:
                "Students under academic warning are not allowed to register for more than 12 credit hours per semester, except in the graduation semester where one additional course may be allowed if required for graduation.",
          ),

          WarningItem(
            text:
                "This rule does not apply to the summer semester, if available.",
          ),

          WarningItem(
            text:
                "A student may also be permanently dismissed according to university regulations regarding failure limits.",
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
