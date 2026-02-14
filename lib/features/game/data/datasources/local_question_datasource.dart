import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mindclash/features/game/data/datasources/question_datasource.dart';
import 'package:mindclash/features/game/data/models/question_model.dart';

/// Loads trivia questions from bundled JSON assets.
///
/// Reads files at `assets/questions/<category>.json`. Accepts an optional
/// [AssetBundle] for testability — production code falls back to
/// [rootBundle].
class LocalQuestionDataSource implements QuestionDataSource {
  /// Creates a [LocalQuestionDataSource] with an optional [bundle] override.
  const LocalQuestionDataSource({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  AssetBundle get _effectiveBundle => _bundle ?? rootBundle;

  @override
  Future<List<QuestionModel>> getQuestions(String category) async {
    try {
      final jsonString = await _effectiveBundle.loadString(
        'assets/questions/$category.json',
      );
      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      // rootBundle.loadString throws FlutterError (an Error subclass) for
      // missing assets. This is an expected condition, not a programming error.
      // ignore: avoid_catching_errors
    } on FlutterError {
      return [];
    }
  }

  @override
  Future<List<String>> getCategories() async {
    // Flutter's rootBundle has no "list files" API, so categories are
    // hardcoded for Phase 1. Phase 2 alternatives:
    //   - Manifest file listing categories
    //   - Directory listing from a remote source
    //   - Database query
    return ['science'];
  }
}
