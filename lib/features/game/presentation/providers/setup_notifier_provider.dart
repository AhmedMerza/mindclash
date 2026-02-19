import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_notifier_provider.freezed.dart';
part 'setup_notifier_provider.g.dart';

/// State for the game setup screen (team names, locale, rounds, categories).
@freezed
abstract class SetupState with _$SetupState {
  /// Creates a [SetupState] with defaults for a 2-team, 3-round game.
  const factory SetupState({
    /// Team name inputs — starts with 2 empty slots.
    @Default(['', '']) List<String> teamNames,

    /// Selected locale code (defaults to Arabic).
    @Default('ar') String locale,

    /// Number of rounds.
    @Default(3) int numberOfRounds,

    /// Selected question categories (minimum 1 required).
    /// Defaults to all categories for maximum variety.
    @Default({
      'science',
      'geography',
      'history',
      'sports',
      'general_knowledge',
    })
    Set<String> selectedCategories,

    /// Whether to automatically select a random category for each question.
    /// When false, user manually selects category during hand-off.
    /// Defaults to false to give players control.
    @Default(false) bool randomCategory,

    /// Whether to automatically select a random difficulty for each question.
    /// When false, user manually selects difficulty during hand-off.
    /// Defaults to false to give players control.
    @Default(false) bool randomDifficulty,

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

  /// Updates a team name at [index].
  void updateTeamName(int index, String name) {
    final names = [...state.teamNames];
    names[index] = name;
    state = state.copyWith(teamNames: names);
  }

  /// Adds an empty team slot (max 4).
  void addTeam() {
    if (state.teamNames.length >= 4) return;
    state = state.copyWith(teamNames: [...state.teamNames, '']);
  }

  /// Removes the team at [index] (min 2).
  void removeTeam(int index) {
    if (state.teamNames.length <= 2) return;
    final names = [...state.teamNames]..removeAt(index);
    state = state.copyWith(teamNames: names);
  }

  /// Sets the question locale (must be 'en' or 'ar').
  void setLocale(String locale) {
    if (locale != 'en' && locale != 'ar') {
      assert(false, 'Unsupported locale: $locale');
      setError('Unsupported language: $locale');
      return;
    }

    // Clear any previous validation errors
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

    state = state.copyWith(locale: locale);
  }

  /// Sets the number of rounds (must be 1-3 for Phase 1).
  void setNumberOfRounds(int rounds) {
    if (rounds < 1 || rounds > 3) {
      assert(false, 'Invalid rounds: $rounds (must be 1-3)');
      setError('Number of rounds must be between 1 and 3');
      return;
    }

    // Clear any previous validation errors
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

    state = state.copyWith(numberOfRounds: rounds);
  }

  /// Sets the selected categories.
  /// At least one category must remain selected.
  /// Categories must be non-empty strings.
  void setSelectedCategories(Set<String> categories) {
    if (categories.isEmpty) {
      // Prevent clearing all categories — keep existing selection
      assert(false, 'Attempted to set empty category set');
      setError('At least one category must be selected');
      return;
    }

    // Validate: filter out empty strings and whitespace
    final validCategories =
        categories.where((c) => c.trim().isNotEmpty).toSet();

    // Check if any categories were filtered out
    if (validCategories.length < categories.length) {
      final invalidCount = categories.length - validCategories.length;
      assert(
        false,
        'Filtered out $invalidCount invalid categories: '
        '${categories.difference(validCategories)}',
      );
    }

    if (validCategories.isEmpty) {
      // All categories were invalid — keep existing selection
      assert(false, 'All provided categories were invalid');
      setError('Invalid categories provided');
      return;
    }

    // Clear any previous validation errors
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

    state = state.copyWith(selectedCategories: validCategories);
  }

  /// Sets whether category selection is random.
  void setRandomCategory(bool value) {
    state = state.copyWith(randomCategory: value);
  }

  /// Sets whether difficulty selection is random.
  void setRandomDifficulty(bool value) {
    state = state.copyWith(randomDifficulty: value);
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
        state.teamNames.map((n) => n.trim()).where((n) => n.isNotEmpty);
    return trimmedNames.length >= 2 &&
        trimmedNames.length == trimmedNames.toSet().length;
  }
}
