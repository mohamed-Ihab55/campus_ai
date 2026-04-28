import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/home_feature/data/cubits/stats_cubit/stats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = [
      ('Doctors', AppColors.primary),
      ('Departments', AppColors.green),
      ('Service', AppColors.amber),
      ('Buildings', AppColors.purple),
    ];

    return BlocProvider(
      create: (_) => StatsCubit()..loadStats(),
      child: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: List.generate(labels.length, (index) {
                final item = labels[index];
                final count =
                    state.stats.isNotEmpty ? state.stats[index].toString() : '0';

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == labels.length - 1 ? 0 : 5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: item.$2.withValues(alpha: 0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          count,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: item.$2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$1,
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
              }),
            ),
          );
        },
      ),
    );
  }
}

