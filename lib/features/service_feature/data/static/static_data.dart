import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/presentation/view/gpa_calculator_screen.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:flutter/material.dart';

List<ServiceItem> getServices(BuildContext context) {
  return [
    const ServiceItem(
      icon: Icons.edit,
      title: 'Course Registration',
      subtitle: 'Add and drop courses',
      bgColor: Color(0xFFEEF2FF),
      borderColor: Color(0xFFC7D2FE),
      accentColor: AppColors.primary,
    ),
    const ServiceItem(
      icon: Icons.receipt,
      title: 'Request Transcript',
      subtitle: 'Official academic transcript',
      bgColor: Color(0xFFEDE9FE),
      borderColor: Color(0xFFDDD6FE),
      accentColor: AppColors.purple,
    ),
    const ServiceItem(
      icon: Icons.warning,
      title: 'Academic Warning',
      subtitle: 'Your current academic status',
      bgColor: Color(0xFFCCFBF1),
      borderColor: Color(0xFF99F6E4),
      accentColor: Colors.black,
    ),
    ServiceItem(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const GpaCalculatorScreen())),
      icon: Icons.calculate,
      title: 'Gpa Calculator',
      subtitle: 'Calculate your current GPA',
      bgColor: const Color(0xFFCCFBF1),
      borderColor: const Color(0xFF99F6E4),
      accentColor: Colors.black,
    ),
  ];
}
