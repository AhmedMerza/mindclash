import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';

/// Shows correct/wrong feedback after answering or skipping a question.
class AnswerResultWidget extends StatelessWidget {
  /// Creates an [AnswerResultWidget].
  const AnswerResultWidget({
    required this.result,
    required this.onContinue,
    super.key,
  });

  /// The result data from the answered/skipped question.
  final PlayResult result;

  /// Called when the player taps "Continue".
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isSkipped = result.selectedIndex == -1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.isCorrect ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: result.isCorrect
                  ? AppColors.success
                  : AppColors.error,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              result.isCorrect
                  ? 'Correct!'
                  : isSkipped
                      ? 'Skipped'
                      : 'Wrong!',
              style: AppTypography.heading.copyWith(
                color: result.isCorrect
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (result.isCorrect)
              Text(
                '+${result.pointsAwarded} points',
                style: AppTypography.subheading.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            if (!result.isCorrect) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Correct answer:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                result.correctAnswerText,
                style: AppTypography.subheading.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
