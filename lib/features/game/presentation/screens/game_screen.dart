import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/presentation/providers/game_notifier_provider.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';
import 'package:mindclash/features/game/presentation/screens/setup_screen.dart';
import 'package:mindclash/features/game/presentation/widgets/answer_result_widget.dart';
import 'package:mindclash/features/game/presentation/widgets/hand_off_widget.dart';
import 'package:mindclash/features/game/presentation/widgets/question_widget.dart';
import 'package:mindclash/features/game/presentation/widgets/results_widget.dart';
import 'package:mindclash/features/game/presentation/widgets/round_end_widget.dart';

/// Main game screen — switches content based on [GameState] and [PlayPhase].
class GameScreen extends ConsumerWidget {
  /// Creates a [GameScreen].
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showQuitDialog(context, notifier);
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (uiState.engineState) {
            GameInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            GamePlaying(:final data) => switch (uiState.playPhase) {
                PlayHandOff() => HandOffWidget(
                    data: data,
                    onShowQuestion: notifier.showQuestion,
                  ),
                PlayAnswering() => QuestionWidget(
                    question: notifier.currentQuestion!,
                    data: data,
                    onAnswer: notifier.answerQuestion,
                    onSkip: notifier.skipQuestion,
                  ),
                final PlayResult result => AnswerResultWidget(
                    result: result,
                    onContinue: notifier.continueToNext,
                  ),
              },
            GamePaused() => const Center(
                child: Text('Paused'),
              ),
            GameRoundEnd(:final data) => RoundEndWidget(
                data: data,
                sortedTeams: notifier.sortedTeamsByScore,
                onNextRound: notifier.nextRound,
                onEndGame: notifier.endGame,
              ),
            GameFinished() => ResultsWidget(
                sortedTeams: notifier.sortedTeamsByScore,
                onPlayAgain: () {
                  unawaited(
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const SetupScreen(),
                      ),
                    ),
                  );
                },
                onHome: () {
                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },
              ),
          },
        ),
      ),
    );
  }

  void _showQuitDialog(BuildContext context, GameNotifier notifier) {
    unawaited(
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Quit Game?', style: AppTypography.subheading),
          content: const Text(
            'Your progress will be lost.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                notifier.endGame();
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              child: const Text(
                'Quit',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
