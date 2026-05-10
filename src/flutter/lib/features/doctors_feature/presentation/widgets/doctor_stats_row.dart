import 'package:flutter/material.dart';

class DoctorsStatsRow extends StatelessWidget {
  final int filtered;
  final int total;
  final VoidCallback onClear;
  final bool showClear;

  const DoctorsStatsRow({
    super.key,
    required this.filtered,
    required this.total,
    required this.onClear,
    required this.showClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('$filtered / $total'),
        ),
        const Spacer(),
        if (showClear)
          TextButton(onPressed: onClear, child: const Text('Clear')),
      ],
    );
  }
}