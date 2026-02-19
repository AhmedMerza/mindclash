import 'package:mindclash/features/game/domain/entities/question.dart';

/// Extension methods for [Question] entity.
///
/// Provides utility methods without modifying the core domain entity.
extension QuestionCategoryExtension on Question {
  /// Infers the category from the question's ID prefix.
  ///
  /// Question IDs follow the pattern: `{category_prefix}_{number}`.
  /// For example:
  /// - `sci_001` → `science`
  /// - `hist_042` → `history`
  /// - `geo_015` → `geography`
  /// - `sport_023` → `sports`
  /// - `gen_007` → `general_knowledge`
  ///
  /// Returns `'unknown'` for IDs that don't match any known prefix.
  /// This is a defensive fallback — all questions in the JSON files
  /// should have valid prefixes.
  String get category {
    final prefix = id.split('_').first;
    return switch (prefix) {
      'sci' => 'science',
      'hist' => 'history',
      'geo' => 'geography',
      'sport' => 'sports',
      'gen' => 'general_knowledge',
      _ => 'unknown',
    };
  }
}
