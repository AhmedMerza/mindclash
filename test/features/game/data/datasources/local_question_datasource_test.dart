import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/data/datasources/local_question_datasource.dart';

void main() {
  group('LocalQuestionDataSource', () {
    late _FakeAssetBundle bundle;
    late LocalQuestionDataSource datasource;

    final sampleQuestions = [
      {
        'id': 'sci_001',
        'text': 'What is H2O?',
        'options': ['Water', 'Salt', 'Sugar', 'Acid'],
        'correctIndex': 0,
        'difficulty': 'easy',
      },
      {
        'id': 'sci_002',
        'text': 'What is the powerhouse of the cell?',
        'options': ['Nucleus', 'Ribosome', 'Mitochondria', 'Golgi'],
        'correctIndex': 2,
        'difficulty': 'medium',
      },
      {
        'id': 'sci_003',
        'text': 'What is the Chandrasekhar limit?',
        'options': ['Star mass', 'Black hole', 'Speed', 'Temperature'],
        'correctIndex': 0,
        'difficulty': 'hard',
      },
    ];

    final arabicQuestions = [
      {
        'id': 'sci_001',
        'text': 'ما هو الرمز الكيميائي للماء؟',
        'options': ['H2O', 'CO2', 'NaCl', 'O2'],
        'correctIndex': 0,
        'difficulty': 'easy',
      },
    ];

    setUp(() {
      bundle = _FakeAssetBundle({
        'assets/questions/en/science.json': json.encode(sampleQuestions),
        'assets/questions/ar/science.json': json.encode(arabicQuestions),
      });
      datasource = LocalQuestionDataSource(bundle: bundle);
    });

    group('getQuestions', () {
      test('returns parsed models for existing category', () async {
        final result = await datasource.getQuestions(
          'science',
          locale: 'en',
        );

        expect(result, hasLength(3));
        expect(result[0].id, 'sci_001');
        expect(result[0].text, 'What is H2O?');
        expect(result[0].options, hasLength(4));
        expect(result[0].correctIndex, 0);
      });

      test('returns empty list for non-existent category', () async {
        final result = await datasource.getQuestions(
          'history',
          locale: 'en',
        );

        expect(result, isEmpty);
      });

      test('parses difficulty as string', () async {
        final result = await datasource.getQuestions(
          'science',
          locale: 'en',
        );

        expect(result[0].difficulty, 'easy');
        expect(result[1].difficulty, 'medium');
        expect(result[2].difficulty, 'hard');
      });

      test('parses optional score field when present', () async {
        final questionsWithScore = [
          {
            'id': 'sci_001',
            'text': 'Q?',
            'options': ['A', 'B', 'C', 'D'],
            'correctIndex': 0,
            'difficulty': 'easy',
            'score': 500,
          },
        ];
        final scoreBundle = _FakeAssetBundle({
          'assets/questions/en/science.json':
              json.encode(questionsWithScore),
        });
        final scoreDatasource = LocalQuestionDataSource(bundle: scoreBundle);

        final result = await scoreDatasource.getQuestions(
          'science',
          locale: 'en',
        );

        expect(result[0].score, 500);
      });

      test('score is null when not present in JSON', () async {
        final result = await datasource.getQuestions(
          'science',
          locale: 'en',
        );

        expect(result[0].score, isNull);
      });

      test('loads correct locale file for Arabic', () async {
        final result = await datasource.getQuestions(
          'science',
          locale: 'ar',
        );

        expect(result, hasLength(1));
        expect(result[0].id, 'sci_001');
        expect(result[0].text, 'ما هو الرمز الكيميائي للماء؟');
      });

      test('returns empty list for missing locale', () async {
        final result = await datasource.getQuestions(
          'science',
          locale: 'fr',
        );

        expect(result, isEmpty);
      });

      test('asserts on empty locale', () {
        expect(
          () => datasource.getQuestions('science', locale: ''),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts on empty category', () {
        expect(
          () => datasource.getQuestions('', locale: 'en'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    test('getQuestions propagates FormatException on malformed JSON', () async {
      final badBundle = _FakeAssetBundle({
        'assets/questions/en/broken.json': '{not valid json array',
      });
      final badDatasource = LocalQuestionDataSource(bundle: badBundle);

      expect(
        () => badDatasource.getQuestions('broken', locale: 'en'),
        throwsA(isA<FormatException>()),
      );
    });

    test('getCategories returns hardcoded list', () async {
      final result = await datasource.getCategories();

      expect(result, [
        'science',
        'geography',
        'history',
        'sports',
        'general_knowledge',
      ]);
    });
  });
}

/// A fake [AssetBundle] that serves pre-loaded string content.
class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final content = _assets[key];
    if (content == null) {
      throw FlutterError('Asset not found: $key');
    }
    return content;
  }

  @override
  Future<ByteData> load(String key) =>
      throw UnimplementedError('Not needed for these tests');
}
