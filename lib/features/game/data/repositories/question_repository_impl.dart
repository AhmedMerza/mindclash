import 'package:mindclash/features/game/data/datasources/question_datasource.dart';
import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/repositories/question_repository.dart';

/// Composite [QuestionRepository] that queries multiple [QuestionDataSource]s
/// in priority order.
///
/// **Phase 1:** `[localSource]`.
/// **Phase 2:** `[cacheSource, remoteSource, localSource]` — first non-empty
/// result wins, zero existing-code changes required.
class QuestionRepositoryImpl implements QuestionRepository {
  /// Creates a repository that queries [sources] in order.
  const QuestionRepositoryImpl({required List<QuestionDataSource> sources})
      : _sources = sources;

  final List<QuestionDataSource> _sources;

  /// Returns questions for [category], optionally filtered by [difficulty].
  ///
  /// Sources are queried in order — the first source that has *any*
  /// questions for [category] wins. Difficulty filtering is applied
  /// **after** source selection, so the result can be empty even when a
  /// source had questions (just none matching the requested difficulty).
  /// Fallback sources are *not* tried in that case — the winning source
  /// is considered authoritative for the category.
  @override
  Future<List<Question>> getQuestions({
    required String category,
    Difficulty? difficulty,
  }) async {
    for (final source in _sources) {
      final models = await source.getQuestions(category);
      if (models.isNotEmpty) {
        var entities = models.map((m) => m.toEntity()).toList();
        if (difficulty != null) {
          entities =
              entities.where((q) => q.difficulty == difficulty).toList();
        }
        return entities;
      }
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    final allCategories = <String>{};
    for (final source in _sources) {
      final categories = await source.getCategories();
      allCategories.addAll(categories);
    }
    return allCategories.toList()..sort();
  }
}
