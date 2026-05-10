import 'package:flutter/material.dart';

class ContainerLoadingState extends StatelessWidget {
  const ContainerLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 0.7, duration: const Duration(milliseconds: 900),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.indigo.shade100,
                width: 1.2,
              ),
            ),
            child: Center(
              child: _line(width: 20, height: 10),
            ),
          ),
          const SizedBox(height: 8,),
          _line(width: 25, height: 10)
        ],
      ),
    );
  }

  Widget _line({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
