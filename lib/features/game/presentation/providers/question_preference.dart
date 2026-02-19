import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_preference.freezed.dart';

/// User's preference for the next question's category and/or difficulty.
///
/// Used when random modes are disabled to allow manual selection during
/// hand-off. Both fields are nullable — `null` means "no preference set"
/// (effectively random for that attribute).
///
/// This is a temporary override that applies only to the next question.
/// After the question is shown, the preference is cleared.
@freezed
abstract class QuestionPreference with _$QuestionPreference {
  /// Creates a [QuestionPreference] with optional category and difficulty.
  const factory QuestionPreference({
    /// Preferred category (e.g., 'science', 'history'). Null = random.
    String? category,

    /// Preferred difficulty (e.g., 'easy', 'medium', 'hard'). Null = random.
    String? difficulty,
  }) = _QuestionPreference;
}
