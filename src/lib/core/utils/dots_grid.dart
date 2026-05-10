import 'package:flutter/material.dart';

class DotsGrid extends StatelessWidget {
  const DotsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            9,
            (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                )),
      ),
    );
  }
}
