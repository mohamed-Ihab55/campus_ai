import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/home_feature/data/cubit/quick_cubit.dart';
import 'package:campus_ai/features/home_feature/data/services/quick_repo.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/feature_label.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/quick_access_row.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/stats_strip.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/time_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccessSection extends StatelessWidget {
  const AccessSection({super.key, required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // pull handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const FeatureLabel(label: 'Access Quick Links'),
            BlocProvider(
              create: (context) => QuickCubit(QuickRepo())..load(),
              child: const QuickAccessRow(),
            ),
            const SizedBox(height: 18),
            const FeatureLabel(label: 'Campus Stats'),
            const StatsStrip(),
            const SizedBox(height: 18),
            const FeatureLabel(label: 'Time Map'),
            const TimeMap(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
