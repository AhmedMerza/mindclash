import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

/// Pure Dart state machine that drives all game logic.
///
/// Deterministic and side-effect-free:
/// ```dart
/// const engine = GameEngine();
/// final newState = engine.process(currentState, action);
/// ```
///
/// Throws [StateError] on invalid transitions — the UI layer
/// is responsible for preventing them.
class GameEngine {
  /// Creates a [GameEngine] instance.
  const GameEngine();

  /// Processes an [action] against the current [state] and returns
  /// the next state. Never mutates — always returns a new instance.
  GameState process(GameState state, GameAction action) {
    return switch (state) {
      GameInitial() => _processInitial(action),
      GamePlaying(:final data) => _processPlaying(data, action),
      GamePaused(:final data) => _processPaused(data, action),
      GameRoundEnd(:final data) => _processRoundEnd(data, action),
      GameFinished() => _invalidTransition(state, action),
    };
  }

  // -- State processors ------------------------------------------------------

  GameState _processInitial(GameAction action) {
    return switch (action) {
      StartGame(:final players, :final config, :final questions) =>
        _handleStartGame(players, config, questions),
      _ => _invalidTransition(const GameState.initial(), action),
    };
  }

  GameState _processPlaying(GameData data, GameAction action) {
    return switch (action) {
      AnswerQuestion(:final selectedIndex) =>
        _handleAnswerQuestion(data, selectedIndex),
      SkipQuestion() => _handleSkipQuestion(data),
      PauseGame() => GameState.paused(data: data),
      EndGame() => GameState.finished(data: data),
      _ => _invalidTransition(GameState.playing(data: data), action),
    };
  }

  GameState _processPaused(GameData data, GameAction action) {
    return switch (action) {
      ResumeGame() => GameState.playing(data: data),
      EndGame() => GameState.finished(data: data),
      _ => _invalidTransition(GameState.paused(data: data), action),
    };
  }

  GameState _processRoundEnd(GameData data, GameAction action) {
    return switch (action) {
      NextRound() => _handleNextRound(data),
      EndGame() => GameState.finished(data: data),
      _ => _invalidTransition(GameState.roundEnd(data: data), action),
    };
  }

  // -- Action handlers -------------------------------------------------------

  GameState _handleStartGame(
    List<Player> players,
    GameConfig config,
    List<Question> questions,
  ) {
    assert(players.isNotEmpty, 'StartGame requires at least one player');
    assert(
      questions.length >= config.numberOfRounds * config.questionsPerRound,
      'StartGame requires at least '
      '${config.numberOfRounds * config.questionsPerRound} questions, '
      'got ${questions.length}',
    );

    return GameState.playing(
      data: GameData(
        players: players,
        questions: questions,
        config: config,
      ),
    );
  }

  GameState _handleAnswerQuestion(GameData data, int selectedIndex) {
    final question = _currentQuestion(data);
    final isCorrect = selectedIndex == question.correctIndex;

    final updatedPlayers = isCorrect
        ? _updatePlayerScore(
            data.players,
            data.currentPlayerIndex,
            question.score,
          )
        : data.players;

    return _advanceToNextQuestion(data.copyWith(players: updatedPlayers));
  }

  GameState _handleSkipQuestion(GameData data) {
    return _advanceToNextQuestion(data);
  }

  GameState _handleNextRound(GameData data) {
    final nextRound = data.currentRound + 1;

    if (nextRound > data.config.numberOfRounds) {
      return GameState.finished(data: data);
    }

    return GameState.playing(
      data: data.copyWith(
        currentRound: nextRound,
        currentQuestionIndex: 0,
        currentPlayerIndex: 0,
      ),
    );
  }

  // -- Helpers ---------------------------------------------------------------

  /// Advances player and question indices. Returns [GameRoundEnd] if the
  /// round's question limit is reached, otherwise [GamePlaying].
  GameState _advanceToNextQuestion(GameData data) {
    final nextPlayerIndex =
        (data.currentPlayerIndex + 1) % data.players.length;
    final nextQuestionIndex = data.currentQuestionIndex + 1;

    final updatedData = data.copyWith(
      currentPlayerIndex: nextPlayerIndex,
      currentQuestionIndex: nextQuestionIndex,
    );

    if (nextQuestionIndex >= data.config.questionsPerRound) {
      return GameState.roundEnd(data: updatedData);
    }

    return GameState.playing(data: updatedData);
  }

  /// Looks up the current question using global indexing:
  /// `(currentRound - 1) * questionsPerRound + currentQuestionIndex`
  Question _currentQuestion(GameData data) {
    final globalIndex = (data.currentRound - 1) *
            data.config.questionsPerRound +
        data.currentQuestionIndex;
    return data.questions[globalIndex];
  }

  /// Returns a new player list with the score at [playerIndex] increased
  /// by [points].
  List<Player> _updatePlayerScore(
    List<Player> players,
    int playerIndex,
    int points,
  ) {
    return [
      for (int i = 0; i < players.length; i++)
        if (i == playerIndex)
          players[i].copyWith(score: players[i].score + points)
        else
          players[i],
    ];
  }

  /// Throws a [StateError] for invalid state/action combinations.
  Never _invalidTransition(GameState state, GameAction action) {
    throw StateError(
      'Invalid transition: ${state.runtimeType} + ${action.runtimeType}',
    );
  }
}
