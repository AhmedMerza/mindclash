import 'dart:math';

import 'package:mindclash/core/extensions/question_extensions.dart';
import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';
import 'package:mindclash/features/game/domain/usecases/game_engine.dart';
import 'package:mindclash/features/game/presentation/providers/game_ui_state.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';
import 'package:mindclash/features/game/presentation/providers/question_preference.dart';
import 'package:mindclash/features/game/presentation/providers/question_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_notifier_provider.g.dart';

/// Central game state notifier.
///
/// Wraps the pure [GameEngine] state machine and manages the UI-only
/// [PlayPhase] sub-state. All game mutations flow through this notifier.
///
/// Supports multi-category question loading and dynamic question selection
/// based on user preferences for category and difficulty.
@Riverpod(keepAlive: true)
class GameNotifier extends _$GameNotifier {
  static const _engine = GameEngine();

  @override
  GameUiState build() {
    return const GameUiState(engineState: GameState.initial());
  }

  /// Loads questions from selected categories and starts a new game.
  Future<void> startGame({
    required List<String> teamNames,
    required String locale,
    required int numberOfRounds,
    required Set<String> selectedCategories,
    required bool randomCategory,
    required bool randomDifficulty,
  }) async {
    try {
      final repo = ref.read(questionRepositoryProvider);
      final allQuestions = <Question>[];

      // Load questions from all selected categories
      for (final category in selectedCategories) {
        final questions = await repo.getQuestions(
          category: category,
          locale: locale,
        );
        allQuestions.addAll(questions);
      }

      // Shuffle entire pool for randomization
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

      final config = GameConfig(
        numberOfRounds: numberOfRounds,
        questionsPerRound: questionsPerRound,
        randomCategory: randomCategory,
        randomDifficulty: randomDifficulty,
      );

      // Reset to initial state first to support "Play Again"
      final newState = _engine.process(
        const GameState.initial(),
        GameAction.startGame(
          teams: teams,
          config: config,
          questions: allQuestions,
        ),
      );

      state = GameUiState(engineState: newState);
    } catch (e) {
      // Rethrow for the caller (SetupScreen) to handle
      rethrow;
    }
  }

  /// Transitions from hand-off to showing the question.
  /// Selects and caches the next question based on filters/preferences.
  void showQuestion() {
    final question = _selectAndCacheNextQuestion();
    if (question == null) {
      // Out of questions - force end game
      endGame();
      return;
    }

    state = state.copyWith(playPhase: const PlayPhase.answering());
  }

  /// Processes an answer: captures result data, dispatches to engine,
  /// then shows the result phase.
  void answerQuestion(int selectedIndex) {
    final question = state.currentQuestion;
    if (question == null) return; // Guard: only callable when question exists
    final isCorrect = selectedIndex == question.correctIndex;
    final points = isCorrect ? question.score : 0;

    final newEngineState = _engine.process(
      state.engineState,
      GameAction.answerQuestion(selectedIndex: selectedIndex),
    );

    // Mark question as used
    final updatedUsedIds = {...state.usedQuestionIds, question.id};

    state = GameUiState(
      engineState: newEngineState,
      usedQuestionIds: updatedUsedIds,
      currentQuestion: question, // Preserve question during result phase
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
    final question = state.currentQuestion;
    if (question == null) return; // Guard: only callable when question exists

    final newEngineState = _engine.process(
      state.engineState,
      const GameAction.skipQuestion(),
    );

    // Mark question as used
    final updatedUsedIds = {...state.usedQuestionIds, question.id};

    state = GameUiState(
      engineState: newEngineState,
      usedQuestionIds: updatedUsedIds,
      currentQuestion: question, // Preserve question during result phase
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
        // Clear the current question and preference when moving to hand-off
        state = state.copyWith(
          playPhase: const PlayPhase.handOff(),
          currentQuestion: null,
          nextQuestionPreference: null,
        );
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

  /// Sets the category preference for the next question.
  void setCategoryPreference(String? category) {
    final current = state.nextQuestionPreference ?? const QuestionPreference();
    state = state.copyWith(
      nextQuestionPreference: current.copyWith(category: category),
    );
  }

  /// Sets the difficulty preference for the next question.
  void setDifficultyPreference(String? difficulty) {
    final current = state.nextQuestionPreference ?? const QuestionPreference();
    state = state.copyWith(
      nextQuestionPreference: current.copyWith(difficulty: difficulty),
    );
  }

  /// Clears the category preference for the next question (one-time randomize).
  void randomizeCategory() {
    setCategoryPreference(null);
  }

  /// Clears the difficulty preference for the next question (one-time randomize).
  void randomizeDifficulty() {
    setDifficultyPreference(null);
  }

  /// Toggles the random category mode in the game config.
  void toggleRandomCategory() {
    final data = _dataOrNull();
    if (data == null) return;

    final newConfig = data.config.copyWith(
      randomCategory: !data.config.randomCategory,
    );

    // Update the game data with new config
    final updatedState = switch (state.engineState) {
      GamePlaying(:final data) =>
        GamePlaying(data: data.copyWith(config: newConfig)),
      GamePaused(:final data) =>
        GamePaused(data: data.copyWith(config: newConfig)),
      GameRoundEnd(:final data) =>
        GameRoundEnd(data: data.copyWith(config: newConfig)),
      GameFinished(:final data) =>
        GameFinished(data: data.copyWith(config: newConfig)),
      GameInitial() => state.engineState,
    };

    state = state.copyWith(engineState: updatedState);
  }

  /// Toggles the random difficulty mode in the game config.
  void toggleRandomDifficulty() {
    final data = _dataOrNull();
    if (data == null) return;

    final newConfig = data.config.copyWith(
      randomDifficulty: !data.config.randomDifficulty,
    );

    // Update the game data with new config
    final updatedState = switch (state.engineState) {
      GamePlaying(:final data) =>
        GamePlaying(data: data.copyWith(config: newConfig)),
      GamePaused(:final data) =>
        GamePaused(data: data.copyWith(config: newConfig)),
      GameRoundEnd(:final data) =>
        GameRoundEnd(data: data.copyWith(config: newConfig)),
      GameFinished(:final data) =>
        GameFinished(data: data.copyWith(config: newConfig)),
      GameInitial() => state.engineState,
    };

    state = state.copyWith(engineState: updatedState);
  }

  /// Selects the next question and caches it in state.
  /// Returns the selected question or null if no questions available.
  Question? _selectAndCacheNextQuestion() {
    final data = _dataOrNull();
    if (data == null) return null;

    final question = _selectNextQuestion(
      allQuestions: data.questions,
      usedIds: state.usedQuestionIds,
      randomCategory: data.config.randomCategory,
      randomDifficulty: data.config.randomDifficulty,
      preference: state.nextQuestionPreference,
    );

    if (question != null) {
      state = state.copyWith(currentQuestion: question);
    }

    return question;
  }

  /// Selects the next question from the pool based on filters and preferences.
  ///
  /// Algorithm:
  /// 1. Single-pass filter with priority scoring
  /// 2. Select from highest priority tier available
  /// 3. Return random question without shuffling (O(1) selection)
  ///
  /// Returns null if all questions have been used.
  ///
  /// Optimized: O(n) single pass, no intermediate lists, random index.
  Question? _selectNextQuestion({
    required List<Question> allQuestions,
    required Set<String> usedIds,
    required bool randomCategory,
    required bool randomDifficulty,
    QuestionPreference? preference,
  }) {
    final preferredCategory = !randomCategory ? preference?.category : null;
    final preferredDifficulty =
        !randomDifficulty ? preference?.difficulty : null;

    // Single-pass categorization by priority
    // Priority 3: Matches both category AND difficulty (best)
    // Priority 2: Matches category only (fallback 1)
    // Priority 1: Unused questions (fallback 2)
    final priority3 = <Question>[];
    final priority2 = <Question>[];
    final priority1 = <Question>[];

    for (final q in allQuestions) {
      // Skip used questions
      if (usedIds.contains(q.id)) continue;

      // Categorize by match quality
      final categoryMatch =
          preferredCategory == null || q.category == preferredCategory;
      final difficultyMatch =
          preferredDifficulty == null || q.difficulty == preferredDifficulty;

      if (categoryMatch && difficultyMatch) {
        priority3.add(q);
      } else if (categoryMatch) {
        priority2.add(q);
      } else {
        priority1.add(q);
      }
    }

    // Select from highest priority pool available
    final pool = priority3.isNotEmpty
        ? priority3
        : priority2.isNotEmpty
            ? priority2
            : priority1;

    if (pool.isEmpty) return null;

    // O(1) random selection without shuffling
    final randomIndex = pool.length == 1 ? 0 : _random.nextInt(pool.length);
    return pool[randomIndex];
  }

  // Random instance for question selection (reused across calls)
  static final _random = Random();

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
