import 'package:flutter/material.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';

/// Reusable ranked team list showing names and scores.
class ScoreboardWidget extends StatelessWidget {
  /// Creates a [ScoreboardWidget] displaying [teams] ranked by score.
  const ScoreboardWidget({
    required this.teams,
    super.key,
  });

  /// Teams sorted by score — caller is responsible for sorting.
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < teams.length; i++)
          _ScoreboardRow(
            rank: i + 1,
            player: teams[i],
          ),
      ],
    );
  }
}

class _ScoreboardRow extends StatelessWidget {
  const _ScoreboardRow({
    required this.rank,
    required this.player,
  });

  final int rank;
  final Team player;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: isFirst
                  ? AppTypography.subheading
                      .copyWith(color: AppColors.secondary)
                  : AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              player.name,
              style: isFirst
                  ? AppTypography.subheading
                  : AppTypography.body,
            ),
          ),
          Text(
            '${player.score}',
            style: isFirst
                ? AppTypography.subheading
                    .copyWith(color: AppColors.secondary)
                : AppTypography.body,
          ),
        ],
      ),
    );
  }
}
