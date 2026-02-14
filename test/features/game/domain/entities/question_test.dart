import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('Question', () {
    const question = Question(
      id: 'sci_001',
      text: 'What is the speed of light?',
      options: ['299,792 km/s', '150,000 km/s', '1,080 km/h', '343 m/s'],
      correctIndex: 0,
      difficulty: 'medium',
      score: 400,
    );

    test('constructs with all fields', () {
      expect(question.id, 'sci_001');
      expect(question.text, 'What is the speed of light?');
      expect(question.options, hasLength(4));
      expect(question.correctIndex, 0);
      expect(question.difficulty, 'medium');
      expect(question.score, 400);
    });

    test('two questions with same fields are equal', () {
      const other = Question(
        id: 'sci_001',
        text: 'What is the speed of light?',
        options: ['299,792 km/s', '150,000 km/s', '1,080 km/h', '343 m/s'],
        correctIndex: 0,
        difficulty: 'medium',
        score: 400,
      );

      expect(question, other);
    });
  });
}
