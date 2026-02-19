/// Game-specific constants for UI configuration.
sealed class GameConstants {
  /// Maximum number of players allowed in a game (Phase 1).
  static const int maxPlayers = 4;

  /// Minimum number of players required to start a game.
  static const int minPlayers = 2;

  /// Maximum number of rounds (limited by 15 questions / 5 per round).
  static const int maxRounds = 3;

  /// Minimum number of rounds.
  static const int minRounds = 1;

  /// Large display font size for emphasis (hand-off screen, results).
  static const double largeFontSize = 36;

  /// Trophy icon size for results screen.
  static const double trophyIconSize = 80;
}
