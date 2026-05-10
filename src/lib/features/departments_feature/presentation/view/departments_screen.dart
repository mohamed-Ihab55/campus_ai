import 'package:campus_ai/features/departments_feature/data/cubit/department_cubit.dart';
import 'package:campus_ai/features/departments_feature/presentation/widgets/departments_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepartmentCubit()..getDepartments(),
      child: DepartmentsScreenBody(),
    );
  }
}
