import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/team.dart';

void main() {
  group('Team', () {
    test('score defaults to 0', () {
      const team = Team(id: 'p1', name: 'Alice');

      expect(team.score, 0);
    });

    test('two teams with same fields are equal', () {
      const a = Team(id: 'p1', name: 'Alice');
      const b = Team(id: 'p1', name: 'Alice');

      expect(a, b);
    });

    test('two teams with different fields are not equal', () {
      const a = Team(id: 'p1', name: 'Alice');
      const b = Team(id: 'p2', name: 'Bob');

      expect(a, isNot(b));
    });

    test('copyWith updates score', () {
      const team = Team(id: 'p1', name: 'Alice');

      final updated = team.copyWith(score: 10);

      expect(updated.score, 10);
      expect(updated.name, 'Alice');
    });
  });
}
