import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final double gpa;
  final bool isSemester;

  const ResultCard({super.key, required this.gpa, required this.isSemester});

  @override
  Widget build(BuildContext context) {
    final status = getAcademicStatus(gpa);

    Color cardColor;
    Color borderColor;
    if (gpa >= 3.60) {
      cardColor = AppColors.greenLight;
      borderColor = AppColors.green;
    } else if (gpa >= 3.00) {
      cardColor = AppColors.primaryLight;
      borderColor = AppColors.primary;
    } else if (gpa >= 2.00) {
      cardColor = AppColors.amberLight;
      borderColor = AppColors.amber;
    } else {
      cardColor = AppColors.redLight;
      borderColor = AppColors.red;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: borderColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'out of 4.00  / 4.00',
                    style: TextStyle(
                      fontSize: 11,
                      color: borderColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor.withValues(alpha: 0.25)),
          const SizedBox(height: 10),

          Text(
            '${status.emoji}  ${status.labelEn}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: borderColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          if (!isSemester)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: status.canGraduate
                    ? AppColors.greenLight
                    : AppColors.redLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: status.canGraduate ? AppColors.green : AppColors.red,
                ),
              ),
              child: Text(
                status.canGraduate
                    ? '✅  Eligible to Graduate'
                    : '⚠️  Not Eligible to Graduate',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: status.canGraduate ? AppColors.green : AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
