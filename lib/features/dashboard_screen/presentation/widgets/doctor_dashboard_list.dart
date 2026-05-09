import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/doctors_cubit/doctors_dashboard_cubit.dart';
import 'doctors_dashboard_card.dart';

class DoctorsDashboardList extends StatelessWidget {
  const DoctorsDashboardList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsDashboardCubit, DoctorsDashboardState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DoctorsLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.doctors.length,
            itemBuilder: (context, index) {
              return DoctorDashboardCard(doctor: state.doctors[index]);
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
