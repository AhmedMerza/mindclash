import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';

/// A trivia question with exactly 4 options.
///
/// Matches the JSON schema: `id`, `text`, `options` (4 strings),
/// `correctIndex` (0-based), `difficulty` (free-form string),
/// `score` (points awarded for a correct answer — always positive).
@freezed
abstract class Question with _$Question {
  /// Creates a [Question] with its [id], [text], answer [options],
  /// [correctIndex], [difficulty] label, and [score].
  @Assert('score > 0', 'score must be positive')
  const factory Question({
    required String id,
    required String text,
    required List<String> options,
    required int correctIndex,
    required String difficulty,
    required int score,
  }) = _Question;

  const Question._();
}
