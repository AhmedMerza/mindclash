import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';

/// A player in the game. Score starts at 0 and is incremented
/// by the engine via `copyWith` as questions are answered.
@freezed
abstract class Player with _$Player {
  /// Creates a [Player] with a unique [id], display [name], and [score].
  const factory Player({
    required String id,
    required String name,
    @Default(0) int score,
  }) = _Player;
}
