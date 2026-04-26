import 'package:campus_ai/features/doctors_feature/data/models/departments.dart';
import 'package:flutter/material.dart';

class DepartmentTabs extends StatelessWidget {
  final Department active;
  final Function(Department) onSelect;

  const DepartmentTabs({
    super.key,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Department.values.map((d) {
          final isActive = d == active;

          return GestureDetector(
            onTap: () => onSelect(d),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                d.label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
