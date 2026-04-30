import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        headlineMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: AppColors.textPrimary),
      scaffoldBackgroundColor: AppColors.bgColor,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.textSecondary,
        tertiary: AppColors.textTertiary!.withValues(alpha: 0.3),

        surface: Colors.blueGrey[50],
        onSurface: AppColors.textPrimary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyMedium: const TextStyle(fontSize: 14, color: Colors.white70),
        headlineMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      // Deep navy background for a professional dark look
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary.withValues(alpha: 0.2),
        secondary: AppColors.primaryDark,
        tertiary: AppColors.textTertiary.withValues(alpha: 0.3),
        brightness: Brightness.dark,
        surface: AppColors.darkSurfaceColor,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      cardColor: AppColors.darkBackgroundColor,
      canvasColor: AppColors.darkBackgroundColor,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBackgroundColor,
      ),
      iconTheme: base.iconTheme.copyWith(color: Colors.white),
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: Colors.white70,
        textColor: Colors.white,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppColors.darkSurfaceColor,
        hintStyle: base.textTheme.bodyMedium?.copyWith(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.darkDialogColor),
    );
  }
}
