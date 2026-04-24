import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StatsStrip extends StatelessWidget {
  final _stats = const [
    ('42', 'Doctors', AppColors.primary),
    ('6', 'Departments', AppColors.green),
    ('18', 'Service', AppColors.amber),
    ('3', 'Buildings', AppColors.purple),
  ];

  const StatsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: _stats.map((s) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: s == _stats.last ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.$2,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
