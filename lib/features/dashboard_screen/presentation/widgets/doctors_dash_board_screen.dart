import 'package:campus_ai/features/dashboard_screen/data/doctors_cubit/doctors_dashboard_cubit.dart';
import 'package:campus_ai/features/dashboard_screen/data/repos/doctor_dashboard_repos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import 'add_doctor_form.dart';
import 'doctor_dashboard_list.dart';

class DoctorsDashboardScreen extends StatelessWidget {
  const DoctorsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorsDashboardCubit(
        DoctorsDashboardRepo(FirebaseFirestore.instance),
      )..getDoctors(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xffF5F7FB),
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
                    Tab(text: 'Add Doctor'),
                    Tab(text: 'Doctors List'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [AddDoctorForm(), DoctorsDashboardList()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


