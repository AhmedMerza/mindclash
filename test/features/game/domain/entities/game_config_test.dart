import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';

void main() {
  group('GameConfig', () {
    test('has sensible defaults', () {
      const config = GameConfig();

      expect(config.numberOfRounds, 3);
      expect(config.questionsPerRound, 5);
      expect(config.timePerQuestionSeconds, isNull);
    });

    test('custom values override defaults', () {
      const config = GameConfig(
        numberOfRounds: 5,
        questionsPerRound: 10,
        timePerQuestionSeconds: 30,
      );

      expect(config.numberOfRounds, 5);
      expect(config.questionsPerRound, 10);
      expect(config.timePerQuestionSeconds, 30);
    });
  });
}
