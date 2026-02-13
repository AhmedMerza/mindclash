import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App entry point.
void main() {
  runApp(const ProviderScope(child: MindClashApp()));
}

/// Root widget for the MindClash application.
class MindClashApp extends StatelessWidget {
  /// Creates a [MindClashApp].
  const MindClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindClash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('MindClash'),
        ),
      ),
    );
  }
}
