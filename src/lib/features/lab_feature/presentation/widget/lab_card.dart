import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LabCard extends StatelessWidget {
  final dynamic lab;

  const LabCard({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            // Add navigation or details logic here
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                lab.labName.isNotEmpty ? lab.labName[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text(
            lab.labName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
