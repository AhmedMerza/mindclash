import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:test/test.dart';

void main() {
  group('Player', () {
    test('score defaults to 0', () {
      const player = Player(id: 'p1', name: 'Alice');

      expect(player.score, 0);
    });

    test('two players with same fields are equal', () {
      const a = Player(id: 'p1', name: 'Alice');
      const b = Player(id: 'p1', name: 'Alice');

      expect(a, b);
    });

    test('two players with different fields are not equal', () {
      const a = Player(id: 'p1', name: 'Alice');
      const b = Player(id: 'p2', name: 'Bob');

      expect(a, isNot(b));
    });

    test('copyWith updates score', () {
      const player = Player(id: 'p1', name: 'Alice');

      final updated = player.copyWith(score: 10);

      expect(updated.score, 10);
      expect(updated.name, 'Alice');
    });
  });
}
