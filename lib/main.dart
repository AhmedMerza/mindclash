import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindclash/app/app.dart';

/// App entry point.
void main() {
  runApp(const ProviderScope(child: MindClashApp()));
}
