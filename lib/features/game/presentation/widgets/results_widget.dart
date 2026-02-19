import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/presentation/widgets/scoreboard_widget.dart';

/// Final results screen with winner announcement and scoreboard.
class ResultsWidget extends StatelessWidget {
  /// Creates a [ResultsWidget].
  const ResultsWidget({
    required this.sortedPlayers,
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  /// Players sorted by score (descending).
  final List<Player> sortedPlayers;

  /// Called when "Play Again" is tapped.
  final VoidCallback onPlayAgain;

  /// Called when "Home" is tapped.
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    if (sortedPlayers.isEmpty) {
      return const Center(child: Text('No players'));
    }
    final winner = sortedPlayers.first;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Game Over!',
              style: AppTypography.heading,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${winner.name} wins!',
              style: AppTypography.subheading.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${winner.score} points',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ScoreboardWidget(players: sortedPlayers),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onPlayAgain,
                child: const Text('Play Again'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onHome,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
                child: const Text('Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
