import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({super.key, this.controller, this.onChanged, required this.hintText, required this.labelText,  this.prefixIcon,  this.suffixIcon, this.obscureText=false, this.keyboardType=TextInputType.text, this.validator});
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String hintText;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 14,color: AppColors.textSecondary),
      cursorColor: AppColors.primary,
      keyboardType:keyboardType,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: labelText,
          labelStyle: TextStyle(color: AppColors.primary),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.5),fontSize: 14),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary),
          )
      ),
    );
  }
}
