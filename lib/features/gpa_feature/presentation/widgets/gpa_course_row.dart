import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/model/gpa_course_model.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GpaCourseRow extends StatelessWidget {
  final int index;
  final GpaCourse course;
  final VoidCallback onRemove;
  final ValueChanged<GpaCourse> onChanged;

  const GpaCourseRow({
    super.key,
    required this.index,
    required this.course,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس الصف: رقم الكورس + زر الحذف ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course ${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
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
          ),
          const SizedBox(height: 8),

          // ── اسم المقرر ─────────────────────────────────────────────────
          TextFormField(
            initialValue: course.name,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: _inputDecoration('Course Name'),
            onChanged: (v) => onChanged(course.copyWith(name: v)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: course.hours.toStringAsFixed(
                    course.hours == course.hours.roundToDouble() ? 0 : 1,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration('Hours'),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0) {
                      onChanged(course.copyWith(hours: parsed));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // التقدير
              Expanded(
                flex: 3,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: course.grade,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: selectableGrades
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                '$g  (${gradePoints[g]!.toStringAsFixed(2)})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onChanged(course.copyWith(grade: v));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
