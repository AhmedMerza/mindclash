import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';

/// Text styles for MindClash.
///
/// Use these instead of inline TextStyles to keep the UI consistent.
sealed class AppTypography {
  /// Large titles — screen headings, game-over text.
  static const heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Medium emphasis — section titles, player names.
  static const subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Default readable text — questions, descriptions.
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Smaller body text — hints, secondary info.
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Smallest text — labels, timestamps, fine print.
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Button labels — slightly spaced, semi-bold.
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
