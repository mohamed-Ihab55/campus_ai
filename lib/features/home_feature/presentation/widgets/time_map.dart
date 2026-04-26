import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/table_cell_text.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/table_header.dart';
import 'package:flutter/material.dart';

class ScheduleItem {
  final String date;
  final String title;

  ScheduleItem(this.date, this.title);
}

class TimeMap extends StatelessWidget {
  const TimeMap({super.key});

  List<ScheduleItem> get data => [
    ScheduleItem('Jan 31, 2026', 'Registration for Spring Semester'),
    ScheduleItem("Feb 7, 2026", "Semester Begins"),
    ScheduleItem("Feb 14 , 2026", "Add/Drop Period"),
    ScheduleItem("Feb 28, 2026", "Practical Work (1)"),
    ScheduleItem("Mar 14, 2026", "Activities & Follow-up"),
    ScheduleItem("Mar 21, 2026", "Practical Work (2)"),
    ScheduleItem("Mar 28, 2026", "Regular Classes"),
    ScheduleItem("Apr 25, 2026", "End of Lectures"),
    ScheduleItem("May 2, 2026", "Final Labs Exams"),
    ScheduleItem("May 16, 2026", "Final Theortical Exams"),
    ScheduleItem("Jun 27, 2026", "Showing of Results"),
    ScheduleItem("Jul 4, 2026", "Registration for summer semester"),
    ScheduleItem("Jul 11, 2026", "Summer Semester Begins"),
    ScheduleItem("Aug 18, 2026", "Final Exams for Summer Semester"),
  ];

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        color: AppColors.surface2,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: TableHeader("Date")),
                  VerticalDivider(width: 1, color: Colors.white),
                  Expanded(flex: 4, child: TableHeader("Event")),
                ],
              ),
            ),

            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = data[index];

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: TableCellText(item.date)),
                      const VerticalDivider(width: 1, color: AppColors.border),
                      Expanded(flex: 4, child: TableCellText(item.title)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
