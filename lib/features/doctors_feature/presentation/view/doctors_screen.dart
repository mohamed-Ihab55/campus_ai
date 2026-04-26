import 'package:campus_ai/features/doctors_feature/data/cubit/doctor_cubit.dart';
import 'package:campus_ai/features/doctors_feature/presentation/widgets/doctors_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorsCubit()..load(),
      child: const DoctorsScreenBody(),
    );
  }
}
