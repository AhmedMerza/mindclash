import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/data/datasources/local_question_datasource.dart';
import 'package:mindclash/features/game/domain/entities/difficulty.dart';

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

    setUp(() {
      bundle = _FakeAssetBundle({
        'assets/questions/science.json': json.encode(sampleQuestions),
      });
      datasource = LocalQuestionDataSource(bundle: bundle);
    });

    group('getQuestions', () {
      test('returns parsed models for existing category', () async {
        final result = await datasource.getQuestions('science');

        expect(result, hasLength(3));
        expect(result[0].id, 'sci_001');
        expect(result[0].text, 'What is H2O?');
        expect(result[0].options, hasLength(4));
        expect(result[0].correctIndex, 0);
      });

      test('returns empty list for non-existent category', () async {
        final result = await datasource.getQuestions('history');

        expect(result, isEmpty);
      });

      test('parses all difficulty levels', () async {
        final result = await datasource.getQuestions('science');

        expect(result[0].difficulty, Difficulty.easy);
        expect(result[1].difficulty, Difficulty.medium);
        expect(result[2].difficulty, Difficulty.hard);
      });
    });

    test('getQuestions propagates FormatException on malformed JSON', () async {
      final badBundle = _FakeAssetBundle({
        'assets/questions/broken.json': '{not valid json array',
      });
      final badDatasource = LocalQuestionDataSource(bundle: badBundle);

      expect(
        () => badDatasource.getQuestions('broken'),
        throwsA(isA<FormatException>()),
      );
    });

    test('getCategories returns hardcoded list', () async {
      final result = await datasource.getCategories();

      expect(result, ['science']);
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
