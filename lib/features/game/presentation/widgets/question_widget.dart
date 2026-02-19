import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_radius.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

/// Displays the current question with answer options.
///
/// Shows a status bar (player name, score, round info), the question text,
/// four answer buttons, and a skip button.
class QuestionWidget extends StatelessWidget {
  /// Creates a [QuestionWidget].
  const QuestionWidget({
    required this.question,
    required this.data,
    required this.onAnswer,
    required this.onSkip,
    super.key,
  });

  /// The question to display.
  final Question question;

  /// Current game data snapshot.
  final GameData data;

  /// Called with the selected option index when an answer is tapped.
  final ValueChanged<int> onAnswer;

  /// Called when the player taps "Skip".
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final player = data.players[data.currentPlayerIndex];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player.name,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Score: ${player.score}',
                style: AppTypography.bodySmall,
              ),
              Text(
                'R${data.currentRound} · '
                'Q${data.currentQuestionIndex + 1}/'
                '${data.config.questionsPerRound}',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Question text + answers
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      question.text,
                      style: AppTypography.subheading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ...List.generate(question.options.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => onAnswer(index),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              side: const BorderSide(
                                color: AppColors.primaryLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.lgAll,
                              ),
                            ),
                            child: Text(
                              question.options[index],
                              style: AppTypography.body,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Skip button
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
