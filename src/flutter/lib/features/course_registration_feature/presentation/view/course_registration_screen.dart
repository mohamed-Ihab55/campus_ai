import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/course_registration_feature/presentation/widgets/download_and_open_file_part.dart';
import 'package:campus_ai/features/course_registration_feature/presentation/widgets/note_card.dart';
import 'package:campus_ai/features/course_registration_feature/presentation/widgets/registration_description.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';

class CourseRegistrationScreen extends StatelessWidget {
  const CourseRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          ServicesHeader(
            height: 250,
            titleName: 'Course',
            subTitle: 'Registration',
            description:
                'Download official course registration forms for students.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: RegistrationDescription(),
                ),
                const SizedBox(height: 26),
                DownloadAndOpenFilePart(),
                const SizedBox(height: 24),
                NoteCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
