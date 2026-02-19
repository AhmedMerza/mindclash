import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';

/// Configuration for a game session.
///
/// [timePerQuestionSeconds] is nullable — Phase 1 has no timer,
/// so it defaults to `null`.
///
/// [randomCategory] and [randomDifficulty] control whether questions are
/// automatically selected or require manual selection during hand-off.
/// Both default to false to give players control over question selection.
@freezed
abstract class GameConfig with _$GameConfig {
  /// Creates a [GameConfig] with round and timing settings.
  const factory GameConfig({
    @Default(3) int numberOfRounds,
    @Default(5) int questionsPerRound,
    int? timePerQuestionSeconds,
    @Default(false) bool randomCategory,
    @Default(false) bool randomDifficulty,
  }) = _GameConfig;
}
