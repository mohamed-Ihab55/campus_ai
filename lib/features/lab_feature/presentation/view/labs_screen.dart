import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/lab_feature/data/cubit/lab_cubit.dart';
import 'package:campus_ai/features/lab_feature/presentation/widget/lab_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabCubit()..getDepartments(),
      child: const Scaffold(
        backgroundColor: AppColors.surface2,
        body: LabScreenBody(),
      ),
    );
  }
}
