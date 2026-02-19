import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';

/// A team in the game. Score starts at 0 and is incremented
/// by the engine via `copyWith` as questions are answered.
@freezed
abstract class Team with _$Team {
  /// Creates a [Team] with a unique [id], display [name], and [score].
  const factory Team({
    required String id,
    required String name,
    @Default(0) int score,
  }) = _Team;
}
