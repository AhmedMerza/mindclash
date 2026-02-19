import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';

part 'game_data.freezed.dart';

/// Shared data carried by every active `GameState` variant
/// (`playing`, `paused`, `roundEnd`, `finished`).
///
/// Extracted to avoid duplicating ~6 fields across each variant.
/// The engine pulls `data` from the current state, transforms it,
/// and wraps it in the new state variant.
@freezed
abstract class GameData with _$GameData {
  /// Creates a [GameData] snapshot with all active game state fields.
  const factory GameData({
    required List<Team> teams,
    required List<Question> questions,
    required GameConfig config,
    @Default(0) int currentTeamIndex,
    @Default(0) int currentQuestionIndex,
    @Default(1) int currentRound,
  }) = _GameData;
}
