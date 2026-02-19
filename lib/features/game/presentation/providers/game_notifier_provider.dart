import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';
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

  // TODO(phase2): Make category configurable when more categories are added
  static const _defaultCategory = 'science';

  @override
  GameUiState build() {
    return const GameUiState(engineState: GameState.initial());
  }

  /// Loads questions and starts a new game.
  Future<void> startGame({
    required List<String> teamNames,
    required String locale,
    required int numberOfRounds,
  }) async {
    try {
      final repo = ref.read(questionRepositoryProvider);
      final allQuestions = await repo.getQuestions(
        category: _defaultCategory,
        locale: locale,
      );

      // Shuffle questions to randomize order for each game session
      allQuestions.shuffle();

      final teams = [
        for (int i = 0; i < teamNames.length; i++)
          Team(id: 'p${i + 1}', name: teamNames[i]),
      ];

      // Adjust questions per round to ensure fair distribution
      // Each team must get the same number of questions per round
      const baseQuestionsPerRound = 5;
      final questionsPerRound =
          (baseQuestionsPerRound ~/ teams.length) * teams.length;

      // Calculate total questions needed and trim the list
      final totalQuestionsNeeded = numberOfRounds * questionsPerRound;
      final questions = allQuestions.take(totalQuestionsNeeded).toList();

      final config = GameConfig(
        numberOfRounds: numberOfRounds,
        questionsPerRound: questionsPerRound,
      );

      // Reset to initial state first to support "Play Again"
      final newState = _engine.process(
        const GameState.initial(),
        GameAction.startGame(
          teams: teams,
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

  /// The current team, or `null` if not in a playing state.
  Team? get currentTeam {
    final data = _dataOrNull();
    if (data == null) return null;
    return data.teams[data.currentTeamIndex];
  }

  /// All teams sorted by score (descending).
  /// Note: Creates a new sorted copy on each call. Acceptable for Phase 1
  /// since this is only called when displaying scoreboard (not in hot path).
  List<Team> get sortedTeamsByScore {
    final data = _dataOrNull();
    if (data == null) return [];
    return [...data.teams]..sort((a, b) => b.score.compareTo(a.score));
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
