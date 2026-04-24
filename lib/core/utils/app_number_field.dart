import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppNumberField extends StatelessWidget {
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const AppNumberField({
    super.key,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
      ],
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      decoration: _decoration(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor: AppColors.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(isFocused: true),
    );
  }

  OutlineInputBorder _border({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: isFocused ? AppColors.primary : AppColors.border,
        width: isFocused ? 1.5 : 1,
      ),
    );
  }
}
