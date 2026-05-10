import 'package:campus_ai/features/gpa_feature/data/cubit/gpa_cubit.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/gpa_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GpaCalculatorScreen extends StatelessWidget {
  const GpaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GpaCubit(),
      child: const GpaScreenBody(),
    );
  }
}
