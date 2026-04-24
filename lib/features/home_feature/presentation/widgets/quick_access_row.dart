import 'package:campus_ai/features/home_feature/presentation/widgets/quick_card.dart';
import 'package:flutter/material.dart';

class QuickAccessRow extends StatelessWidget {
  final _items = const [
    (Icons.person_2_outlined, 'Doctors', Color(0x4009637E), Color(0x30088395)),
    (Icons.map_outlined, 'Map', Color(0x40FF8C00), Color(0x50FF8C00)),
    (
      Icons.design_services_outlined,
      'Student Service',
      Color(0x50D6DAC8),
      Color(0x80D6DAC8)
    ),
    (Icons.domain, 'Departments', Color(0x80B7E5CD), Color(0xFFB7E5CD)),
    (Icons.computer_outlined, 'Labs', Color(0xFFFFE4E6), Color(0xFFFECACA)),
  ];

  const QuickAccessRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = _items[i];
          return QuickCard(
            icon: item.$1,
            label: item.$2,
            bgColor: item.$3,
            borderColor: item.$4,
          );
        },
      ),
    );
  }
}
