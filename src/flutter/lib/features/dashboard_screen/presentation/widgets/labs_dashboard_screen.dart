import 'package:campus_ai/features/dashboard_screen/presentation/widgets/add_lab_screen.dart';
import 'package:campus_ai/features/lab_feature/data/cubit/lab_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../lab_feature/presentation/widget/lab_card.dart';
import '../../data/cubits/add_lab_cubit/add_lab_cubit.dart';
class LabsDashboardScreen extends StatelessWidget {
  const LabsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                dividerColor: AppColors.primary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: AppColors.surface,
                unselectedLabelColor: AppColors.textTertiary,
                tabs: const [
                  Tab(text: 'Add Labs'),
                  Tab(text: 'Labs List'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BlocProvider(
                    create: (_) => LabsDashboardCubit(),
                    child: const AddLabScreen()
                  ),
                  BlocProvider(
                    create: (_) => LabCubit()..getDepartments(),
                    child: BlocBuilder<LabCubit, LabState>(
                      builder: (context, state) {
                        if (state is LabLoading) {
                          return _buildLoadingState();
                        } else if (state is LabError) {
                          return _buildErrorState(state.message, context);
                        } else if (state is LabSuccess) {
                          return state.labs.isEmpty
                              ? _buildEmptyState()
                              : _buildLabsList(state.labs);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabsList(List labs) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: labs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => LabCard(lab: labs[index]),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDeep),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 64,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        const Text(
          "No Labs Found",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => context.read<LabCubit>().getDepartments(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
