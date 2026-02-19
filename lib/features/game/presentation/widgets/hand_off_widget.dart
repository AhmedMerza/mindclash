import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';

/// Pass-the-device screen shown between turns.
///
/// Displays the next team's name and a "Show Question" button.
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
    if (data.currentTeamIndex >= data.teams.length) {
      return const Center(child: Text('Invalid team index'));
    }
    final player = data.teams[data.currentTeamIndex];
    final questionNumber = data.currentQuestionIndex + 1;
    final totalQuestions = data.config.questionsPerRound;

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Round ${data.currentRound} of ${data.config.numberOfRounds}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Question $questionNumber of $totalQuestions',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                player.name,
                style: AppTypography.heading.copyWith(
                  color: AppColors.secondary,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                "It's your turn!",
                style: AppTypography.subheading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
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
      ),
    );
  }
}
