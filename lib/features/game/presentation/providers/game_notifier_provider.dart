import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/usecases/game_engine.dart';
import 'package:mindclash/features/game/presentation/providers/game_ui_state.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';
import 'package:mindclash/features/game/presentation/providers/question_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_notifier_provider.g.dart';

/// Central game state notifier.
///
/// Wraps the pure [GameEngine] state machine and manages the UI-only
/// [PlayPhase] sub-state. All game mutations flow through this notifier.
@Riverpod(keepAlive: true)
class GameNotifier extends _$GameNotifier {
  static const _engine = GameEngine();

  @override
  GameUiState build() {
    return const GameUiState(engineState: GameState.initial());
  }

  /// Loads questions and starts a new game.
  Future<void> startGame({
    required List<String> playerNames,
    required String locale,
    required int numberOfRounds,
  }) async {
    try {
      final repo = ref.read(questionRepositoryProvider);
      final questions = await repo.getQuestions(
        category: 'science',
        locale: locale,
      );

    final players = [
      for (int i = 0; i < playerNames.length; i++)
        Player(id: 'p${i + 1}', name: playerNames[i]),
    ];

    final config = GameConfig(numberOfRounds: numberOfRounds);

      // Reset to initial state first to support "Play Again"
      final newState = _engine.process(
        const GameState.initial(),
        GameAction.startGame(
          players: players,
          config: config,
          questions: questions,
        ),
      );

      state = GameUiState(engineState: newState);
    } catch (e) {
      // Rethrow for the caller (SetupScreen) to handle
      rethrow;
    }
  }

  /// Transitions from hand-off to showing the question.
  void showQuestion() {
    state = state.copyWith(playPhase: const PlayPhase.answering());
  }

  /// Processes an answer: captures result data, dispatches to engine,
  /// then shows the result phase.
  void answerQuestion(int selectedIndex) {
    final question = currentQuestion;
    if (question == null) return; // Guard: only callable when question exists
    final isCorrect = selectedIndex == question.correctIndex;
    final points = isCorrect ? question.score : 0;

    final newEngineState = _engine.process(
      state.engineState,
      GameAction.answerQuestion(selectedIndex: selectedIndex),
    );

    state = GameUiState(
      engineState: newEngineState,
      playPhase: PlayPhase.result(
        selectedIndex: selectedIndex,
        isCorrect: isCorrect,
        pointsAwarded: points,
        correctAnswerText: question.options[question.correctIndex],
      ),
    );
  }

  /// Skips the current question (0 points).
  void skipQuestion() {
    final question = currentQuestion;
    if (question == null) return; // Guard: only callable when question exists

    final newEngineState = _engine.process(
      state.engineState,
      const GameAction.skipQuestion(),
    );

    state = GameUiState(
      engineState: newEngineState,
      playPhase: PlayPhase.result(
        selectedIndex: -1,
        isCorrect: false,
        pointsAwarded: 0,
        correctAnswerText: question.options[question.correctIndex],
      ),
    );
  }

  /// After viewing the result, continue to the next turn or round end.
  void continueToNext() {
    switch (state.engineState) {
      case GamePlaying():
        state = state.copyWith(playPhase: const PlayPhase.handOff());
      case GameRoundEnd():
      case GameFinished():
        break;
      default:
        break;
    }
  }

  /// Advances to the next round.
  void nextRound() {
    final newState = _engine.process(
      state.engineState,
      const GameAction.nextRound(),
    );

    state = GameUiState(engineState: newState);
  }

  /// Pauses the game.
  void pauseGame() {
    final newState = _engine.process(
      state.engineState,
      const GameAction.pauseGame(),
    );
    state = state.copyWith(engineState: newState);
  }

  /// Resumes a paused game.
  void resumeGame() {
    final newState = _engine.process(
      state.engineState,
      const GameAction.resumeGame(),
    );
    state = state.copyWith(engineState: newState);
  }

  /// Ends the game immediately.
  void endGame() {
    final newState = _engine.process(
      state.engineState,
      const GameAction.endGame(),
    );
    state = GameUiState(engineState: newState);
  }

  /// The current question, or `null` if not in a playing state.
  Question? get currentQuestion {
    final data = _dataOrNull();
    if (data == null) return null;
    final globalIndex = (data.currentRound - 1) *
            data.config.questionsPerRound +
        data.currentQuestionIndex;
    if (globalIndex >= data.questions.length) return null;
    return data.questions[globalIndex];
  }

  /// The current player, or `null` if not in a playing state.
  Player? get currentPlayer {
    final data = _dataOrNull();
    if (data == null) return null;
    return data.players[data.currentPlayerIndex];
  }

  /// All players sorted by score (descending).
  List<Player> get sortedPlayersByScore {
    final data = _dataOrNull();
    if (data == null) return [];
    return [...data.players]..sort((a, b) => b.score.compareTo(a.score));
  }

  GameData? _dataOrNull() {
    return switch (state.engineState) {
      GamePlaying(:final data) => data,
      GamePaused(:final data) => data,
      GameRoundEnd(:final data) => data,
      GameFinished(:final data) => data,
      GameInitial() => null,
    };
  }
}
