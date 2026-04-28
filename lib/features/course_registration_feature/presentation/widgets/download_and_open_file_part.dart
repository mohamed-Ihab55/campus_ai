import 'dart:io';
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAndOpenFilePart extends StatelessWidget {
  const DownloadAndOpenFilePart({super.key});

  Future<void> downloadAndOpenFile() async {
    try {
      final data = await rootBundle.load(
        'assets/files/course_registration.pdf',
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/course_registration.pdf');

      await file.writeAsBytes(data.buffer.asUint8List());

      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint("Error opening file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryDeep.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Course Registration Forms",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Official PDF forms for students",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: 'Download & Open',
            backgroundColor: AppColors.primary,
            onTap: downloadAndOpenFile,
          ),
        ],
      ),
    );
  }
}
