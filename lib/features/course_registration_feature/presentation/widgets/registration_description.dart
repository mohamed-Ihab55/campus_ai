import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RegistrationDescription extends StatelessWidget {
  const RegistrationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.description_outlined, color: Colors.white, size: 34),
        SizedBox(height: 14),
        Text(
          "Registration Forms",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Download official course registration forms for adding, dropping, overload requests, and graduation course opening.\nMake sure to fill out the correct form based on your academic situation and submit it to your academic advisor for approval.",
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
