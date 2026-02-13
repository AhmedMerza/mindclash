import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mindclash/features/game/domain/entities/game_data.dart';

part 'game_state.freezed.dart';

/// The game's state machine states.
///
/// Uses a sealed union so Dart enforces exhaustive pattern matching:
/// ```dart
/// switch (state) {
///   case GameInitial(): ...
///   case GamePlaying(:final data): ...
///   case GamePaused(:final data): ...
///   case GameRoundEnd(:final data): ...
///   case GameFinished(:final data): ...
/// }
/// ```
@freezed
sealed class GameState with _$GameState {
  const factory GameState.initial() = GameInitial;
  const factory GameState.playing({required GameData data}) = GamePlaying;
  const factory GameState.paused({required GameData data}) = GamePaused;
  const factory GameState.roundEnd({required GameData data}) = GameRoundEnd;
  const factory GameState.finished({required GameData data}) = GameFinished;
}
