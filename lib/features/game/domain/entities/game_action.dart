import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

part 'game_action.freezed.dart';

/// Actions dispatched to the game engine to trigger state transitions.
///
/// [StartGame] carries the full payload (players, config, questions)
/// so the engine stays pure with no repository dependencies.
/// A use case loads questions and builds config before dispatching.
@freezed
sealed class GameAction with _$GameAction {
  const factory GameAction.startGame({
    required List<Player> players,
    required GameConfig config,
    required List<Question> questions,
  }) = StartGame;

  const factory GameAction.answerQuestion({
    required int selectedIndex,
  }) = AnswerQuestion;

  const factory GameAction.skipQuestion() = SkipQuestion;
  const factory GameAction.nextRound() = NextRound;
  const factory GameAction.endGame() = EndGame;
}
