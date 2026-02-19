import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_notifier_provider.freezed.dart';
part 'setup_notifier_provider.g.dart';

/// State for the game setup screen (player names, locale, rounds).
@freezed
abstract class SetupState with _$SetupState {
  /// Creates a [SetupState] with defaults for a 2-player, 3-round game.
  const factory SetupState({
    /// Player name inputs — starts with 2 empty slots.
    @Default(['', '']) List<String> playerNames,

    /// Selected locale code.
    @Default('en') String locale,

    /// Number of rounds.
    @Default(3) int numberOfRounds,

    /// Whether the start-game action is in progress.
    @Default(false) bool isLoading,

    /// Error message from a failed start attempt.
    String? errorMessage,
  }) = _SetupState;
}

/// Manages the setup form state before a game starts.
@riverpod
class SetupNotifier extends _$SetupNotifier {
  @override
  SetupState build() => const SetupState();

  /// Updates a player name at [index].
  void updatePlayerName(int index, String name) {
    final names = [...state.playerNames];
    names[index] = name;
    state = state.copyWith(playerNames: names);
  }

  /// Adds an empty player slot (max 4).
  void addPlayer() {
    if (state.playerNames.length >= 4) return;
    state = state.copyWith(playerNames: [...state.playerNames, '']);
  }

  /// Removes the player at [index] (min 2).
  void removePlayer(int index) {
    if (state.playerNames.length <= 2) return;
    final names = [...state.playerNames]..removeAt(index);
    state = state.copyWith(playerNames: names);
  }

  /// Sets the question locale (must be 'en' or 'ar').
  void setLocale(String locale) {
    assert(locale == 'en' || locale == 'ar', 'Unsupported locale: $locale');
    state = state.copyWith(locale: locale);
  }

  /// Sets the number of rounds (must be 1-3 for Phase 1).
  void setNumberOfRounds(int rounds) {
    assert(rounds >= 1 && rounds <= 3, 'rounds must be 1-3, got: $rounds');
    state = state.copyWith(numberOfRounds: rounds.clamp(1, 3));
  }

  /// Sets the loading flag.
  void setLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Sets an error message and clears loading.
  void setError(String? message) {
    state = state.copyWith(errorMessage: message, isLoading: false);
  }

  /// Whether the form is valid and ready to start.
  bool get isValid {
    final trimmedNames =
        state.playerNames.map((n) => n.trim()).where((n) => n.isNotEmpty);
    return trimmedNames.length >= 2 &&
        trimmedNames.length == trimmedNames.toSet().length;
  }
}
