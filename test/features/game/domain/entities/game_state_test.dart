import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';

void main() {
  const data = GameData(
    teams: [Team(id: 'p1', name: 'Alice')],
    questions: [
      Question(
        id: 'q1',
        text: 'Q?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'easy',
        score: 200,
      ),
    ],
    config: GameConfig(),
  );

  group('GameState', () {
    test('initial variant constructs', () {
      const state = GameInitial();

      expect(state, isA<GameState>());
      expect(state, isA<GameInitial>());
    });

    test('playing variant carries data', () {
      const state = GamePlaying(data: data);

      expect(state, isA<GameState>());
      expect(state.data.teams, hasLength(1));
    });

    test('paused variant carries data', () {
      const state = GamePaused(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('roundEnd variant carries data', () {
      const state = GameRoundEnd(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('finished variant carries data', () {
      const state = GameFinished(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('exhaustive pattern matching works', () {
      const GameState state = GamePlaying(data: data);

      final label = switch (state) {
        GameInitial() => 'initial',
        GamePlaying() => 'playing',
        GamePaused() => 'paused',
        GameRoundEnd() => 'roundEnd',
        GameFinished() => 'finished',
      };

      expect(label, 'playing');
    });
  });
}
