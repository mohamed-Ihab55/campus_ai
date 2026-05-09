import 'package:flutter/material.dart';

class HorizontalFilter extends StatelessWidget {
  const HorizontalFilter({
    super.key,
    this.gradient,
    this.color,
    this.boxShadow,
    this.onTap,
    required this.scale,
    this.fontWeight,
    required this.text,
    this.border, this.animatedColor, this.textColor,
  });
  final Gradient? gradient;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final void Function()? onTap;
  final double scale;
  final FontWeight? fontWeight;
  final String text;
  final BoxBorder? border;
  final Color? animatedColor;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        color: color,
        border: border,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: scale,
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: animatedColor,
                    ),
                  ),

                  const SizedBox(width: 8),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
