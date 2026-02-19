import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';

/// Pass-the-device screen shown between turns.
///
/// Displays the next player's name and a "Show Question" button.
/// Prevents accidental question reveals in pass-and-play mode.
class HandOffWidget extends StatelessWidget {
  /// Creates a [HandOffWidget].
  const HandOffWidget({
    required this.data,
    required this.onShowQuestion,
    super.key,
  });

  /// Current game data snapshot.
  final GameData data;

  /// Called when the player taps "Show Question".
  final VoidCallback onShowQuestion;

  @override
  Widget build(BuildContext context) {
    final player = data.players[data.currentPlayerIndex];
    final questionNumber = data.currentQuestionIndex + 1;
    final totalQuestions = data.config.questionsPerRound;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Round ${data.currentRound} of ${data.config.numberOfRounds}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Question $questionNumber of $totalQuestions',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Text(
              player.name,
              style: AppTypography.heading.copyWith(
                color: AppColors.secondary,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              "It's your turn!",
              style: AppTypography.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onShowQuestion,
                child: const Text('Show Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
