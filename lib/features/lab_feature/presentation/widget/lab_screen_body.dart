import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/lab_feature/data/cubit/lab_cubit.dart';
import 'package:campus_ai/features/lab_feature/presentation/widget/lab_card.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LabScreenBody extends StatelessWidget {
  const LabScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ServicesHeader(
          height: 250,
          titleName: 'College',
          subTitle: 'Labs',
          description: 'Explore the various labs in the college.',
        ),
        Expanded(
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
    );
  }


  Widget _buildLabsList(List labs) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: labs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => LabCard(lab: labs[index]),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
          "No Departments Found",
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
