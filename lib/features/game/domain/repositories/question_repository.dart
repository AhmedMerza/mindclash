import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

/// Contract for retrieving trivia questions.
///
/// The domain layer defines *what* we need — implementations in the data
/// layer decide *how* (local JSON, remote API, cache, etc.).
abstract interface class QuestionRepository {
  /// Returns questions for [category], optionally filtered by [difficulty].
  ///
  /// Returns an empty list when the category has no questions (or no
  /// questions match the difficulty filter).
  Future<List<Question>> getQuestions({
    required String category,
    Difficulty? difficulty,
  });

  /// Returns the list of available category identifiers.
  Future<List<String>> getCategories();
}
