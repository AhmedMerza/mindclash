/// Difficulty levels for trivia questions.
///
/// Plain Dart enum — no codegen needed. The data layer handles
/// JSON string ↔ enum mapping in `QuestionModel`.
enum Difficulty {
  /// Easy difficulty.
  easy,

  /// Medium difficulty.
  medium,

  /// Hard difficulty.
  hard,
}
