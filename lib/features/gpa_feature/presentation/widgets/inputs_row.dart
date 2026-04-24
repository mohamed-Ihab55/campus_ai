import 'package:campus_ai/core/utils/app_number_field.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:flutter/material.dart';

class InputsRow extends StatelessWidget {
  final SemesterEntry entry;
  final ValueChanged<SemesterEntry> onChanged;

  const InputsRow({super.key,
    required this.entry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppNumberField(
            hint: 'Semester GPA',
            initialValue: entry.gpa.toStringAsFixed(2),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null && parsed >= 0 && parsed <= 4) {
                onChanged(
                  SemesterEntry(gpa: parsed, hours: entry.hours),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppNumberField(
            hint: 'Hours',
            initialValue: entry.hours.toStringAsFixed(0),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null && parsed > 0) {
                onChanged(
                  SemesterEntry(gpa: entry.gpa, hours: parsed),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
