import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/presentation/widgets/scoreboard_widget.dart';

/// Shown at the end of each round with standings and next-round option.
class RoundEndWidget extends StatelessWidget {
  /// Creates a [RoundEndWidget].
  const RoundEndWidget({
    required this.data,
    required this.sortedPlayers,
    required this.onNextRound,
    required this.onEndGame,
    super.key,
  });

  /// Current game data snapshot.
  final GameData data;

  /// Players sorted by score (descending).
  final List<Player> sortedPlayers;

  /// Called when "Next Round" is tapped. Null if this is the last round.
  final VoidCallback? onNextRound;

  /// Called when "End Game" or "See Results" is tapped.
  final VoidCallback onEndGame;

  bool get _isLastRound => data.currentRound >= data.config.numberOfRounds;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Round ${data.currentRound} Complete!',
              style: AppTypography.heading.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ScoreboardWidget(players: sortedPlayers),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLastRound ? onEndGame : onNextRound,
                child: Text(
                  _isLastRound ? 'See Results' : 'Next Round',
                ),
              ),
            ),
            if (!_isLastRound) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: onEndGame,
                child: Text(
                  'End Game',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
