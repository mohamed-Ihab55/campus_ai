import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/search_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/cubits/doctors_cubit/doctors_dashboard_cubit.dart';
import 'doctors_dashboard_card.dart';

class DoctorsDashboardList extends StatelessWidget {
  const DoctorsDashboardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchTextField(
          cursorColor: AppColors.primaryDeep,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryDeep),
            borderRadius: BorderRadius.circular(16),
          ),
          textColor: AppColors.textPrimary,
          iconAndTextColor: AppColors.textPrimary,
          fillColor: AppColors.green,
          hintText: 'Search doctors...',
          onChanged: (value) {
            context
                .read<DoctorsDashboardCubit>()
                .setSearchQuery(value);
          },
        ),

        Expanded(
          child: BlocBuilder<DoctorsDashboardCubit,
              DoctorsDashboardState>(
            builder: (context, state) {
              if (state is DoctorsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is DoctorsLoaded) {
                return ListView.builder(
                  padding:const EdgeInsets.only(left: 16,right: 16),
                  itemCount: state.doctors.length,
                  itemBuilder: (context, index) {
                    return DoctorDashboardCard(
                      doctor: state.doctors[index],
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}