import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';

void main() {
  group('GameData', () {
    const teams = [
      Team(id: 'p1', name: 'Alice'),
      Team(id: 'p2', name: 'Bob'),
    ];

    const questions = [
      Question(
        id: 'q1',
        text: 'Question 1?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'easy',
        score: 200,
      ),
    ];

    const config = GameConfig();

    test('index defaults are 0 and round defaults to 1', () {
      const data = GameData(
        teams: teams,
        questions: questions,
        config: config,
      );

      expect(data.currentTeamIndex, 0);
      expect(data.currentQuestionIndex, 0);
      expect(data.currentRound, 1);
    });

    test('copyWith advances question index', () {
      const data = GameData(
        teams: teams,
        questions: questions,
        config: config,
      );

      final next = data.copyWith(currentQuestionIndex: 1);

      expect(next.currentQuestionIndex, 1);
      expect(next.currentTeamIndex, 0);
    });
  });
}
