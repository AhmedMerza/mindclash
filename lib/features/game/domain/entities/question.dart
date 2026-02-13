import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mindclash/features/game/domain/entities/difficulty.dart';

part 'question.freezed.dart';

/// A trivia question with exactly 4 options.
///
/// Matches the JSON schema: `id`, `text`, `options` (4 strings),
/// `correctIndex` (0-based), `difficulty`.
@freezed
abstract class Question with _$Question {
  /// Creates a [Question] with its [id], [text], answer [options],
  /// [correctIndex], and [difficulty].
  const factory Question({
    required String id,
    required String text,
    required List<String> options,
    required int correctIndex,
    required Difficulty difficulty,
  }) = _Question;
}
