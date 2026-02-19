import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';
import 'package:mindclash/features/game/presentation/providers/question_preference.dart';

part 'game_ui_state.freezed.dart';

/// Composite state that the game UI watches.
///
/// Wraps the domain [GameState] with a [PlayPhase] sub-state that only
/// matters when the engine is in the `playing` state. This keeps
/// presentation concerns out of the domain layer.
///
/// Also tracks question selection state: IDs of used questions,
/// user's preference for the next question, and the currently displayed question.
@freezed
abstract class GameUiState with _$GameUiState {
  /// Creates a [GameUiState] combining engine state with UI play phase.
  const factory GameUiState({
    /// The domain-level engine state.
    required GameState engineState,

    /// UI-only sub-phase within the playing state.
    @Default(PlayPhase.handOff()) PlayPhase playPhase,

    /// IDs of questions that have already been shown in this game.
    /// Prevents duplicate questions.
    @Default(<String>{}) Set<String> usedQuestionIds,

    /// User's preference for the next question's category/difficulty.
    /// Cleared after the question is shown. Null = no preference (random).
    QuestionPreference? nextQuestionPreference,

    /// The question currently being displayed/answered.
    /// Cached here to avoid re-selecting on rebuilds.
    Question? currentQuestion,
  }) = _GameUiState;
}
