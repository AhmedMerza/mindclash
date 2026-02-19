import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/presentation/screens/setup_screen.dart';

/// Landing screen with the app title and a button to start a new game.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt,
                size: 80,
                color: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'MindClash',
                style: AppTypography.heading.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Test your knowledge!',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SetupScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Start Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
