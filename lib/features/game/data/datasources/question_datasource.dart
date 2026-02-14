import 'package:mindclash/features/game/data/models/question_model.dart';

/// Strategy interface for a single question source.
///
/// Each implementation knows how to load questions from one place
/// (local assets, remote API, cache, etc.). The repository composes
/// multiple sources and queries them in priority order.
abstract interface class QuestionDataSource {
  /// Returns all questions for [category], or an empty list when the
  /// category is unavailable from this source.
  Future<List<QuestionModel>> getQuestions(String category);

  /// Returns the categories available from this source.
  Future<List<String>> getCategories();
}
