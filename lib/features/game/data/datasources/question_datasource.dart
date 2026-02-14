import 'package:mindclash/features/game/data/models/question_model.dart';

/// Strategy interface for a single question source.
///
/// Each implementation knows how to load questions from one place
/// (local assets, remote API, cache, etc.). The repository composes
/// multiple sources and queries them in priority order.
abstract interface class QuestionDataSource {
  /// Returns all questions for [category] in the given [locale], or an
  /// empty list when the category is unavailable from this source.
  ///
  /// **Security note:** [locale] and [category] are interpolated into file
  /// paths or URLs by implementations. The local asset-bundle source is
  /// safe (sandboxed), but filesystem- or network-based sources must
  /// validate these values to prevent path-traversal attacks.
  Future<List<QuestionModel>> getQuestions(
    String category, {
    required String locale,
  });

  /// Returns the categories available from this source.
  Future<List<String>> getCategories();
}
