import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_radius.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/presentation/providers/game_notifier_provider.dart';
import 'package:mindclash/features/game/presentation/providers/setup_notifier_provider.dart';
import 'package:mindclash/features/game/presentation/screens/game_screen.dart';

/// Setup screen for configuring player names, locale, and round count.
class SetupScreen extends ConsumerStatefulWidget {
  /// Creates a [SetupScreen].
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _controllers
      ..add(TextEditingController())
      ..add(TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(int count) {
    while (_controllers.length < count) {
      _controllers.add(TextEditingController());
    }
    while (_controllers.length > count) {
      _controllers.removeLast().dispose();
    }
  }

  Future<void> _startGame() async {
    final notifier = ref.read(setupProvider.notifier);
    if (!notifier.isValid) return;

    final setupState = ref.read(setupProvider);
    notifier.setLoading(isLoading: true);

    try {
      final gameNotifier = ref.read(gameProvider.notifier);
      final trimmedNames = setupState.playerNames
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .toList();

      await gameNotifier.startGame(
        playerNames: trimmedNames,
        locale: setupState.locale,
        numberOfRounds: setupState.numberOfRounds,
      );

      if (!mounted) return;

      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const GameScreen(),
          ),
        ),
      );
    } on Exception catch (e) {
      notifier.setError('Failed to load questions. Please try again.');
      // Log the actual error for debugging
      debugPrint('Error loading questions: $e');
    } finally {
      notifier.setLoading(isLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(setupProvider);
    final notifier = ref.read(setupProvider.notifier);

    _syncControllers(setupState.playerNames.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Players', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.md),

            ...List.generate(setupState.playerNames.length, (index) {
              return Padding(
                key: ValueKey('player_input_$index'),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          hintText: 'Player ${index + 1}',
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.textDisabled,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.lgAll,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        style: AppTypography.body,
                        onChanged: (value) =>
                            notifier.updatePlayerName(index, value),
                      ),
                    ),
                    if (setupState.playerNames.length > 2)
                      IconButton(
                        onPressed: () => notifier.removePlayer(index),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              );
            }),

            if (setupState.playerNames.length < 4)
              TextButton.icon(
                onPressed: notifier.addPlayer,
                icon: const Icon(Icons.add, color: AppColors.primaryLight),
                label: Text(
                  'Add Player',
                  style: AppTypography.body.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            const Text('Language', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ar', label: Text('Arabic')),
              ],
              selected: {setupState.locale},
              onSelectionChanged: (selected) {
                notifier.setLocale(selected.first);
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.surface,
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            const Text('Rounds', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
              ],
              selected: {setupState.numberOfRounds},
              onSelectionChanged: (selected) {
                notifier.setNumberOfRounds(selected.first);
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.surface,
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            if (setupState.errorMessage != null) ...[
              Text(
                setupState.errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    setupState.isLoading || !notifier.isValid
                        ? null
                        : _startGame,
                child: setupState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
