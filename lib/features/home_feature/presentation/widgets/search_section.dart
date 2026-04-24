import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.fillColor,
    this.border,
    required this.hintText,
    this.iconAndTextColor,
    this.cursorColor,
    this.textColor,
  });
  final Color fillColor;
  final InputBorder? border;
  final String hintText;
  final Color? iconAndTextColor;
  final Color? cursorColor;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 13,
          color: textColor ?? Colors.white,
        ),
        cursorColor: cursorColor ?? Colors.white,
        decoration: InputDecoration(
          enabledBorder: border ?? InputBorder.none,
          focusedBorder: border ?? InputBorder.none,
          disabledBorder: border ?? InputBorder.none,
          fillColor: fillColor,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: iconAndTextColor ?? Colors.white.withValues(alpha: 0.22),
          ),
          prefixIcon: Icon(Icons.search,
              size: 16,
              color: iconAndTextColor ?? Colors.white.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
