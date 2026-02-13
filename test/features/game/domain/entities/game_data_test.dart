import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('GameData', () {
    const players = [
      Player(id: 'p1', name: 'Alice'),
      Player(id: 'p2', name: 'Bob'),
    ];

    const questions = [
      Question(
        id: 'q1',
        text: 'Question 1?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: Difficulty.easy,
      ),
    ];

    const config = GameConfig();

    test('index defaults are 0 and round defaults to 1', () {
      const data = GameData(
        players: players,
        questions: questions,
        config: config,
      );

      expect(data.currentPlayerIndex, 0);
      expect(data.currentQuestionIndex, 0);
      expect(data.currentRound, 1);
    });

    test('copyWith advances question index', () {
      const data = GameData(
        players: players,
        questions: questions,
        config: config,
      );

      final next = data.copyWith(currentQuestionIndex: 1);

      expect(next.currentQuestionIndex, 1);
      expect(next.currentPlayerIndex, 0);
    });
  });
}
