import 'package:flutter/material.dart';

/// Centralized color palette for MindClash.
///
/// Derived from the logo: deep navy background, bright blue primary,
/// gold secondary, red accent, with a lightning bolt white.
sealed class AppColors {
  /// Blue — left side of the "M" in the logo.
  static const primary = Color(0xFF2B8FE3);

  /// Lighter variant of [primary].
  static const primaryLight = Color(0xFF5DB1F5);

  /// Darker variant of [primary].
  static const primaryDark = Color(0xFF1A6BB5);

  /// Gold/amber — right side of the "M", brain, crowns.
  static const secondary = Color(0xFFFDB515);

  /// Lighter variant of [secondary].
  static const secondaryLight = Color(0xFFFFCF4A);

  /// Darker variant of [secondary].
  static const secondaryDark = Color(0xFFD49600);

  /// Red — card elements in the logo.
  static const accent = Color(0xFFE5383B);

  /// Lighter variant of [accent].
  static const accentLight = Color(0xFFFF6B6B);

  /// Darker variant of [accent].
  static const accentDark = Color(0xFFBA1A1D);

  /// Deep navy — main app background.
  static const background = Color(0xFF0A1128);

  /// Slightly lighter navy — cards, dialogs, containers.
  static const surface = Color(0xFF1A2744);

  /// Even lighter surface for hover/pressed states.
  static const surfaceLight = Color(0xFF243352);

  /// High-contrast white for headings and important text.
  static const textPrimary = Color(0xFFFFFFFF);

  /// Muted gray-blue for secondary text.
  static const textSecondary = Color(0xFFB0BEC5);

  /// Dimmed text for disabled elements.
  static const textDisabled = Color(0xFF546E7A);

  /// Green for correct answers and success states.
  static const success = Color(0xFF4CAF50);

  /// Red for wrong answers and error states.
  static const error = Color(0xFFEF5350);

  /// Amber for caution and time-running-out states.
  static const warning = Color(0xFFFFA726);

  /// Subtle line between sections.
  static const divider = Color(0xFF2A3F5F);
}
