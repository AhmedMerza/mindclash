import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_theme.dart';
import 'package:mindclash/features/game/presentation/screens/home_screen.dart';

/// Custom scroll behavior that removes overscroll glow and bounce effects.
class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return child without glow wrapper
    return child;
  }
}

/// Root widget for the MindClash application.
class MindClashApp extends StatelessWidget {
  /// Creates a [MindClashApp].
  const MindClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindClash',
      theme: AppTheme.light(),
      home: const HomeScreen(),
      scrollBehavior: NoOverscrollBehavior(),
    );
  }
}
