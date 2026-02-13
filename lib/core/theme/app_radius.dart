import 'package:flutter/material.dart';

/// Border radius constants for consistent rounded corners.
sealed class AppRadius {
  /// 4px — subtle rounding for small elements.
  static const double sm = 4;

  /// 8px — default rounding for cards, inputs.
  static const double md = 8;

  /// 12px — medium rounding for containers.
  static const double lg = 12;

  /// 16px — prominent rounding for dialogs, sheets.
  static const double xl = 16;

  /// 24px — pill-like rounding for buttons, chips.
  static const double xxl = 24;

  /// Pre-built [BorderRadius] using [sm].
  static final smAll = BorderRadius.circular(sm);

  /// Pre-built [BorderRadius] using [md].
  static final mdAll = BorderRadius.circular(md);

  /// Pre-built [BorderRadius] using [lg].
  static final lgAll = BorderRadius.circular(lg);

  /// Pre-built [BorderRadius] using [xl].
  static final xlAll = BorderRadius.circular(xl);

  /// Pre-built [BorderRadius] using [xxl].
  static final xxlAll = BorderRadius.circular(xxl);
}
