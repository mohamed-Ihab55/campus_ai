import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final ServiceItem item;

  const ServiceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: item.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: item.accentColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: item.borderColor),
              ),
              child: Icon(item.icon, size: 22, color: AppColors.primaryDeep),
            ),

            const Spacer(),

            /// title
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            /// subtitle
            Text(
              item.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "open",
                  style: TextStyle(
                    color: item.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: item.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
