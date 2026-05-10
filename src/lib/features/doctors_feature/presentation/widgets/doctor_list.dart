import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';
import 'package:campus_ai/features/doctors_feature/presentation/widgets/doctor_card.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_colors.dart';

class DoctorsList extends StatelessWidget {
  final List<Doctor> doctors;
  final bool grid;

  const DoctorsList({
    super.key,
    required this.doctors,
    required this.grid,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(child: Text('No doctors found', style: TextStyle(color: AppColors.textSecondary),));
    }

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (_, i) => DoctorCard(doctor: doctors[i]),
    );
  }
}