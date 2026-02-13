import 'package:mindclash/features/game/domain/entities/difficulty.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:test/test.dart';

void main() {
  final data = GameData(
    players: const [Player(id: 'p1', name: 'Alice')],
    questions: const [
      Question(
        id: 'q1',
        text: 'Q?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: Difficulty.easy,
      ),
    ],
    config: const GameConfig(),
  );

  group('GameState', () {
    test('initial variant constructs', () {
      const state = GameInitial();

      expect(state, isA<GameState>());
      expect(state, isA<GameInitial>());
    });

    test('playing variant carries data', () {
      final state = GamePlaying(data: data);

      expect(state, isA<GameState>());
      expect(state.data.players, hasLength(1));
    });

    test('paused variant carries data', () {
      final state = GamePaused(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('roundEnd variant carries data', () {
      final state = GameRoundEnd(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('finished variant carries data', () {
      final state = GameFinished(data: data);

      expect(state, isA<GameState>());
      expect(state.data, data);
    });

    test('exhaustive pattern matching works', () {
      final GameState state = GamePlaying(data: data);

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
