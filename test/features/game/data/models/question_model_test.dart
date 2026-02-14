import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/data/models/question_model.dart';
import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

void main() {
  group('QuestionModel', () {
    const model = QuestionModel(
      id: 'sci_001',
      text: 'What is the chemical symbol for water?',
      options: ['H2O', 'CO2', 'NaCl', 'O2'],
      correctIndex: 0,
      difficulty: Difficulty.easy,
    );

    final validJson = {
      'id': 'sci_001',
      'text': 'What is the chemical symbol for water?',
      'options': ['H2O', 'CO2', 'NaCl', 'O2'],
      'correctIndex': 0,
      'difficulty': 'easy',
    };

    group('fromJson', () {
      test('parses all fields correctly including difficulty enum', () {
        final result = QuestionModel.fromJson(validJson);

        expect(result.id, 'sci_001');
        expect(result.text, 'What is the chemical symbol for water?');
        expect(result.options, ['H2O', 'CO2', 'NaCl', 'O2']);
        expect(result.correctIndex, 0);
        expect(result.difficulty, Difficulty.easy);
      });

      test('parses all difficulty levels', () {
        for (final difficulty in Difficulty.values) {
          final json = {...validJson, 'difficulty': difficulty.name};
          final result = QuestionModel.fromJson(json);
          expect(result.difficulty, difficulty);
        }
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
    });

    test('toEntity maps all fields to domain Question', () {
      final entity = model.toEntity();

      expect(entity, isA<Question>());
      expect(entity.id, model.id);
      expect(entity.text, model.text);
      expect(entity.options, model.options);
      expect(entity.correctIndex, model.correctIndex);
      expect(entity.difficulty, model.difficulty);
    });

    test('fromEntity maps all fields from domain Question', () {
      const entity = Question(
        id: 'sci_002',
        text: 'What planet is the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctIndex: 1,
        difficulty: Difficulty.medium,
      );

      final result = QuestionModel.fromEntity(entity);

      expect(result.id, entity.id);
      expect(result.text, entity.text);
      expect(result.options, entity.options);
      expect(result.correctIndex, entity.correctIndex);
      expect(result.difficulty, entity.difficulty);
    });
  });
}
