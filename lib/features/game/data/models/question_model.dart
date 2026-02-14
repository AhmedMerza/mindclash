import 'package:json_annotation/json_annotation.dart';
import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';

part 'question_model.g.dart';

/// Thin serialization DTO for trivia questions.
///
/// Maps 1-to-1 with the JSON schema in `assets/questions/`. Uses
/// `json_serializable` for codegen — Freezed is reserved for domain
/// entities where immutability/equality semantics matter.
@JsonSerializable()
class QuestionModel {
  /// Creates a [QuestionModel] with all required fields.
  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });

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
      );

  /// Unique identifier, category-prefixed (e.g. `sci_001`).
  final String id;

  /// The question text.
  final String text;

  /// Exactly 4 answer options.
  final List<String> options;

  /// 0-based index of the correct answer in [options].
  final int correctIndex;

  /// The difficulty level.
  final Difficulty difficulty;

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  /// Converts this DTO to a domain [Question] entity.
  Question toEntity() => Question(
        id: id,
        text: text,
        options: List.unmodifiable(options),
        correctIndex: correctIndex,
        difficulty: difficulty,
      );
}
