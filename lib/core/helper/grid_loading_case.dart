import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridLoadingCase extends StatelessWidget {
  const GridLoadingCase({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: 0.7, duration: const Duration(milliseconds: 900),
        child: Container(
          width: 240,
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.indigo.shade100,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              const Spacer(),

              _line(
                width: 120,
                height: 18,
              ),

              const SizedBox(height: 12),

              _line(
                width: 170,
                height: 12,
              ),

              const SizedBox(height: 8),

              _line(
                width: 130,
                height: 12,
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  _line(
                    width: 45,
                    height: 14,
                  ),

                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
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