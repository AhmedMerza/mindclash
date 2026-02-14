import 'package:json_annotation/json_annotation.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

part 'question_model.g.dart';

/// Thin serialization DTO for trivia questions.
///
/// Maps 1-to-1 with the JSON schema in `assets/questions/`. Uses
/// `json_serializable` for codegen — Freezed is reserved for domain
/// entities where immutability/equality semantics matter.
@JsonSerializable(includeIfNull: false)
class QuestionModel {
  /// Creates a [QuestionModel] with all required fields.
  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    this.score,
  }) : assert(score == null || score > 0, 'score must be positive when set');

  /// Deserializes a [QuestionModel] from a JSON map.
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  /// Creates a model from the domain [Question] entity.
  factory QuestionModel.fromEntity(Question entity) => QuestionModel(
        id: entity.id,
        text: entity.text,
        options: entity.options,
        correctIndex: entity.correctIndex,
        difficulty: entity.difficulty,
        score: entity.score,
      );

  // -- Known difficulty labels ------------------------------------------------

  /// Well-known difficulty label for easy questions (default score: 200).
  static const difficultyEasy = 'easy';

  /// Well-known difficulty label for medium questions (default score: 400).
  static const difficultyMedium = 'medium';

  /// Well-known difficulty label for hard questions (default score: 600).
  static const difficultyHard = 'hard';

  /// Fallback score for unknown difficulty labels.
  static const defaultFallbackScore = 400;

  // -- Fields -----------------------------------------------------------------

  /// Unique identifier, category-prefixed (e.g. `sci_001`).
  final String id;

  /// The question text.
  final String text;

  /// Exactly 4 answer options.
  final List<String> options;

  /// 0-based index of the correct answer in [options].
  final int correctIndex;

  /// The difficulty label (free-form: `"easy"`, `"hard"`, `"nightmare"`, etc.).
  final String difficulty;

  /// Optional explicit score override. When `null`, [defaultScore] resolves
  /// the value based on [difficulty].
  final int? score;

  /// Resolves score for [toEntity]: explicit value wins, else default by label.
  static int defaultScore(String difficulty) {
    return switch (difficulty) {
      difficultyEasy => 200,
      difficultyMedium => 400,
      difficultyHard => 600,
      _ => defaultFallbackScore,
    };
  }

  /// Serializes this model to a JSON map.
  ///
  /// Null fields (e.g. [score] when not explicitly set) are omitted.
  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  /// Converts this DTO to a domain [Question] entity.
  ///
  /// Score resolution: explicit [score] wins, otherwise [defaultScore]
  /// determines the value from the [difficulty] label.
  Question toEntity() => Question(
        id: id,
        text: text,
        options: List.unmodifiable(options),
        correctIndex: correctIndex,
        difficulty: difficulty,
        score: score ?? defaultScore(difficulty),
      );
}
