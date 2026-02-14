import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/data/models/question_model.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('QuestionModel', () {
    const model = QuestionModel(
      id: 'sci_001',
      text: 'What is the chemical symbol for water?',
      options: ['H2O', 'CO2', 'NaCl', 'O2'],
      correctIndex: 0,
      difficulty: 'easy',
    );

    final validJson = {
      'id': 'sci_001',
      'text': 'What is the chemical symbol for water?',
      'options': ['H2O', 'CO2', 'NaCl', 'O2'],
      'correctIndex': 0,
      'difficulty': 'easy',
    };

    group('fromJson', () {
      test('parses all fields correctly', () {
        final result = QuestionModel.fromJson(validJson);

        expect(result.id, 'sci_001');
        expect(result.text, 'What is the chemical symbol for water?');
        expect(result.options, ['H2O', 'CO2', 'NaCl', 'O2']);
        expect(result.correctIndex, 0);
        expect(result.difficulty, 'easy');
        expect(result.score, isNull);
      });

      test('parses optional score field', () {
        final json = {...validJson, 'score': 500};
        final result = QuestionModel.fromJson(json);

        expect(result.score, 500);
      });

      test('accepts any difficulty string', () {
        final json = {...validJson, 'difficulty': 'nightmare'};
        final result = QuestionModel.fromJson(json);

        expect(result.difficulty, 'nightmare');
      });

      test('throws on invalid data', () {
        final badJson = {'id': 'sci_001'};
        expect(
          () => QuestionModel.fromJson(badJson),
          throwsA(isA<Error>()),
        );
      });
    });

    test('toJson/fromJson round-trip produces equal fields', () {
      final json = model.toJson();
      final roundTripped = QuestionModel.fromJson(json);

      expect(roundTripped.id, model.id);
      expect(roundTripped.text, model.text);
      expect(roundTripped.options, model.options);
      expect(roundTripped.correctIndex, model.correctIndex);
      expect(roundTripped.difficulty, model.difficulty);
      expect(roundTripped.score, model.score);
    });

    group('toEntity', () {
      test('maps all fields to domain Question', () {
        final entity = model.toEntity();

        expect(entity, isA<Question>());
        expect(entity.id, model.id);
        expect(entity.text, model.text);
        expect(entity.options, model.options);
        expect(entity.correctIndex, model.correctIndex);
        expect(entity.difficulty, model.difficulty);
      });

      test('defaults score by label when no explicit score', () {
        const easyModel = QuestionModel(
          id: 'q1',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
        );
        expect(easyModel.toEntity().score, 200);

        const mediumModel = QuestionModel(
          id: 'q2',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'medium',
        );
        expect(mediumModel.toEntity().score, 400);

        const hardModel = QuestionModel(
          id: 'q3',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'hard',
        );
        expect(hardModel.toEntity().score, 600);
      });

      test('explicit score overrides default', () {
        const overridden = QuestionModel(
          id: 'q1',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'easy',
          score: 500,
        );

        expect(overridden.toEntity().score, 500);
      });

      test('unknown label without score gets fallback of 400', () {
        const custom = QuestionModel(
          id: 'q1',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'nightmare',
        );

        expect(custom.toEntity().score, 400);
      });

      test('unknown label with explicit score uses explicit value', () {
        const custom = QuestionModel(
          id: 'q1',
          text: 'Q?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          difficulty: 'nightmare',
          score: 1000,
        );

        expect(custom.toEntity().score, 1000);
      });
    });

    test('fromEntity maps all fields from domain Question', () {
      const entity = Question(
        id: 'sci_002',
        text: 'What planet is the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctIndex: 1,
        difficulty: 'medium',
        score: 400,
      );

      final result = QuestionModel.fromEntity(entity);

      expect(result.id, entity.id);
      expect(result.text, entity.text);
      expect(result.options, entity.options);
      expect(result.correctIndex, entity.correctIndex);
      expect(result.difficulty, entity.difficulty);
      expect(result.score, entity.score);
    });

    group('defaultScore', () {
      test('returns 200 for easy', () {
        expect(QuestionModel.defaultScore('easy'), 200);
      });

      test('returns 400 for medium', () {
        expect(QuestionModel.defaultScore('medium'), 400);
      });

      test('returns 600 for hard', () {
        expect(QuestionModel.defaultScore('hard'), 600);
      });

      test('returns 400 for unknown labels', () {
        expect(QuestionModel.defaultScore('nightmare'), 400);
        expect(QuestionModel.defaultScore('bonus round'), 400);
        expect(QuestionModel.defaultScore(''), 400);
      });
    });
  });
}
