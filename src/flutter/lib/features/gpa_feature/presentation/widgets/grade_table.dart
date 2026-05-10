import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/table_cell.dart';
import 'package:flutter/material.dart';

class GradeTable extends StatelessWidget {
  const GradeTable({super.key});

  static const _rows = [
    ('A', '4.00', '≥ 90%'),
    ('A-', '3.67', '85–90%'),
    ('B+', '3.33', '80–85%'),
    ('B', '3.00', '75–80%'),
    ('C+', '2.67', '70–75%'),
    ('C', '2.33', '65–70%'),
    ('D', '2.00', '60–65%'),
    ('F', '0.00', '< 60%'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          Icon(Icons.table_chart_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Grade Table',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: AppColors.border),
        ),
        children: [
          _buildHeaderRow(),
          ..._rows.map(_buildDataRow),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: AppColors.primaryLight),
      children: [
        TableCellElement('Grade', isHeader: true),
        TableCellElement('Points', isHeader: true),
        TableCellElement('Range', isHeader: true),
      ],
    );
  }

  TableRow _buildDataRow((String, String, String) row) {
    return TableRow(
      children: [
        TableCellElement(
          row.$1,
          isPrimary: true,
        ),
        TableCellElement(row.$2),
        TableCellElement(row.$3, isSecondary: true),
      ],
    );
  }
}
