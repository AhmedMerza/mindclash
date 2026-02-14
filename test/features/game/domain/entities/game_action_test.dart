import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('GameAction', () {
    test('startGame carries players, config, and questions', () {
      const action = StartGame(
        players: [Player(id: 'p1', name: 'Alice')],
        config: GameConfig(),
        questions: [
          Question(
            id: 'q1',
            text: 'Q?',
            options: ['A', 'B', 'C', 'D'],
            correctIndex: 0,
            difficulty: 'easy',
            score: 200,
          ),
        ],
      );

      expect(action, isA<GameAction>());
      expect(action.players, hasLength(1));
      expect(action.config.numberOfRounds, 3);
      expect(action.questions, hasLength(1));
    });

    test('answerQuestion carries selectedIndex', () {
      const action = AnswerQuestion(selectedIndex: 2);

      expect(action, isA<GameAction>());
      expect(action.selectedIndex, 2);
    });

    test('skipQuestion constructs', () {
      const action = SkipQuestion();

      expect(action, isA<GameAction>());
    });

    test('nextRound constructs', () {
      const action = NextRound();

      expect(action, isA<GameAction>());
    });

    test('endGame constructs', () {
      const action = EndGame();

      expect(action, isA<GameAction>());
    });

    test('pauseGame constructs', () {
      const action = PauseGame();

      expect(action, isA<GameAction>());
    });

    test('resumeGame constructs', () {
      const action = ResumeGame();

      expect(action, isA<GameAction>());
    });

    test('exhaustive pattern matching works', () {
      const GameAction action = AnswerQuestion(selectedIndex: 1);

      final label = switch (action) {
        StartGame() => 'start',
        AnswerQuestion() => 'answer',
        SkipQuestion() => 'skip',
        NextRound() => 'nextRound',
        PauseGame() => 'pause',
        ResumeGame() => 'resume',
        EndGame() => 'end',
      };

      expect(label, 'answer');
    });
  });
}
