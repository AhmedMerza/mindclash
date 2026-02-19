import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_phase.freezed.dart';

/// UI-only sub-state within the "playing" engine state.
///
/// The domain GameEngine only knows "playing". The UI needs three
/// distinct views during a turn:
/// 1. **handOff** — pass the device to the next team
/// 2. **answering** — question visible, waiting for input
/// 3. **result** — correct/wrong feedback after answering
///
/// This is pure presentation state — it does NOT live in the domain layer.
@freezed
sealed class PlayPhase with _$PlayPhase {
  /// Pass-the-device screen between turns.
  const factory PlayPhase.handOff() = PlayHandOff;

  /// Question is visible, awaiting player input.
  const factory PlayPhase.answering() = PlayAnswering;

  /// Answer result feedback shown after answering or skipping.
  const factory PlayPhase.result({
    required int selectedIndex,
    required bool isCorrect,
    required int pointsAwarded,
    required String correctAnswerText,
  }) = PlayResult;
}
