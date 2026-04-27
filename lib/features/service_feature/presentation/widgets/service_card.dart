import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  final ServiceItem item;
  const ServiceCard({
    super.key,
    required this.item,
  });
  @override
  State<ServiceCard> createState() => ServiceCardState();
}

class ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.item.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.item.accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.item.bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.item.borderColor, width: 1),
              ),
              child: Center(
                child: Icon(
                  widget.item.icon,
                  size: 22,
                ),
              ),
            ),
            const Spacer(),

            // title
            Text(
              widget.item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),

            // subtitle
            Text(
              widget.item.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: 10),

            // arrow row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'open',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.item.accentColor,
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: widget.item.bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: widget.item.borderColor),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: widget.item.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
