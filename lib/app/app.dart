import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_theme.dart';

/// Root widget for the MindClash application.
class MindClashApp extends StatelessWidget {
  /// Creates a [MindClashApp].
  const MindClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindClash',
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Text('MindClash'),
        ),
      ),
    );
  }
}
