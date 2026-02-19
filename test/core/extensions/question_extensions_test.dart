import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/core/extensions/question_extensions.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('QuestionCategoryExtension', () {
    group('category', () {
      test('returns "science" for sci_ prefix', () {
        const question = Question(
          id: 'sci_001',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
          score: 200,
        );

        expect(question.category, 'science');
      });

      test('returns "history" for hist_ prefix', () {
        const question = Question(
          id: 'hist_042',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'medium',
          score: 400,
        );

        expect(question.category, 'history');
      });

      test('returns "geography" for geo_ prefix', () {
        const question = Question(
          id: 'geo_015',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'hard',
          score: 600,
        );

        expect(question.category, 'geography');
      });

      test('returns "sports" for sport_ prefix', () {
        const question = Question(
          id: 'sport_023',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
          score: 200,
        );

        expect(question.category, 'sports');
      });

      test('returns "general_knowledge" for gen_ prefix', () {
        const question = Question(
          id: 'gen_007',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'medium',
          score: 400,
        );

        expect(question.category, 'general_knowledge');
      });

      test('returns "unknown" for unrecognized prefix', () {
        const question = Question(
          id: 'xyz_999',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
          score: 200,
        );

        expect(question.category, 'unknown');
      });

      test('returns "unknown" for ID without underscore', () {
        const question = Question(
          id: 'invalidid',
          text: 'Test question',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
          score: 200,
        );

        expect(question.category, 'unknown');
      });
    });
  });
}
