import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
      child: Material(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(doctor.avatarColor).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    doctor.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      '${doctor.title} • ${doctor.department}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'room',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.room,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(
                                    doctor.avatarColor,
                                  ).withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}