import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/doctors_dashboard_model.dart';
import 'edit_doctor_screen.dart';

class DoctorDashboardCard extends StatelessWidget {
  final DoctorsDashboardModel doctor;

  const DoctorDashboardCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditDoctorScreen(
              doctor: doctor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(doctor.avatarColor).withValues(alpha: 0.7),
              child: Text(
                doctor.initials,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(doctor.title,style: TextStyle(color: AppColors.textSecondary,fontSize: 14),),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined,color: AppColors.textSecondary,),
          ],
        ),
      ),
    );
  }
}

