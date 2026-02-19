import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';

part 'game_ui_state.freezed.dart';

/// Composite state that the game UI watches.
///
/// Wraps the domain [GameState] with a [PlayPhase] sub-state that only
/// matters when the engine is in the `playing` state. This keeps
/// presentation concerns out of the domain layer.
@freezed
abstract class GameUiState with _$GameUiState {
  /// Creates a [GameUiState] combining engine state with UI play phase.
  const factory GameUiState({
    /// The domain-level engine state.
    required GameState engineState,

    /// UI-only sub-phase within the playing state.
    @Default(PlayPhase.handOff()) PlayPhase playPhase,
  }) = _GameUiState;
}
