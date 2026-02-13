import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_radius.dart';
import 'package:mindclash/core/theme/app_typography.dart';

/// Builds the app-wide [ThemeData] from our design tokens.
sealed class AppTheme {
  /// Light theme — despite the dark background, this is our "default" theme.
  /// The dark navy background is intentional for a game aesthetic.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.background,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTypography.heading,
        headlineSmall: AppTypography.subheading,
        bodyLarge: AppTypography.body,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        bodyMedium: AppTypography.caption,
      ),
    );
  }
}
