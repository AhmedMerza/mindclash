import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/presentation/providers/setup_notifier_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SetupNotifier', () {
    test('initial state has 2 empty player names', () {
      final state = container.read(setupProvider);

      expect(state.playerNames, ['', '']);
      expect(state.locale, 'en');
      expect(state.numberOfRounds, 3);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updatePlayerName updates at index', () {
      container.read(setupProvider.notifier).updatePlayerName(0, 'Alice');

      expect(container.read(setupProvider).playerNames[0], 'Alice');
    });

    test('addPlayer appends an empty name', () {
      container.read(setupProvider.notifier).addPlayer();

      final names = container.read(setupProvider).playerNames;
      expect(names.length, 3);
      expect(names.last, '');
    });

    test('addPlayer does nothing when already at 4 players', () {
      container.read(setupProvider.notifier)
        ..addPlayer()
        ..addPlayer()
        ..addPlayer(); // ignored — already at 4

      expect(container.read(setupProvider).playerNames.length, 4);
    });

    test('removePlayer removes at index', () {
      container.read(setupProvider.notifier)
        ..addPlayer()
        ..updatePlayerName(0, 'Alice')
        ..updatePlayerName(1, 'Bob')
        ..updatePlayerName(2, 'Charlie')
        ..removePlayer(1);

      final names = container.read(setupProvider).playerNames;
      expect(names, ['Alice', 'Charlie']);
    });

    test('removePlayer does nothing when only 2 players', () {
      container.read(setupProvider.notifier).removePlayer(0);

      expect(container.read(setupProvider).playerNames.length, 2);
    });

    test('setLocale updates locale', () {
      container.read(setupProvider.notifier).setLocale('ar');

      expect(container.read(setupProvider).locale, 'ar');
    });

    test('setNumberOfRounds updates round count', () {
      container.read(setupProvider.notifier).setNumberOfRounds(1);

      expect(container.read(setupProvider).numberOfRounds, 1);
    });

    test('setLoading updates loading flag', () {
      container.read(setupProvider.notifier).setLoading(isLoading: true);

      expect(container.read(setupProvider).isLoading, isTrue);
    });

    test('setError sets message and clears loading', () {
      container.read(setupProvider.notifier)
        ..setLoading(isLoading: true)
        ..setError('Something went wrong');

      final state = container.read(setupProvider);
      expect(state.errorMessage, 'Something went wrong');
      expect(state.isLoading, isFalse);
    });

    test('setError with null clears the error', () {
      container.read(setupProvider.notifier)
        ..setError('Error')
        ..setError(null);

      expect(container.read(setupProvider).errorMessage, isNull);
    });

    group('isValid', () {
      test('returns false with empty names', () {
        expect(container.read(setupProvider.notifier).isValid, isFalse);
      });

      test('returns false with only one name filled', () {
        container.read(setupProvider.notifier).updatePlayerName(0, 'Alice');

        expect(container.read(setupProvider.notifier).isValid, isFalse);
      });

      test('returns true with two unique names', () {
        container.read(setupProvider.notifier)
          ..updatePlayerName(0, 'Alice')
          ..updatePlayerName(1, 'Bob');

        expect(container.read(setupProvider.notifier).isValid, isTrue);
      });

      test('returns false with duplicate names', () {
        container.read(setupProvider.notifier)
          ..updatePlayerName(0, 'Alice')
          ..updatePlayerName(1, 'Alice');

        expect(container.read(setupProvider.notifier).isValid, isFalse);
      });

      test('trims whitespace before validation', () {
        container.read(setupProvider.notifier)
          ..updatePlayerName(0, '  Alice  ')
          ..updatePlayerName(1, '  Bob  ');

        expect(container.read(setupProvider.notifier).isValid, isTrue);
      });

      test('returns false when trimmed names are duplicates', () {
        container.read(setupProvider.notifier)
          ..updatePlayerName(0, '  Alice  ')
          ..updatePlayerName(1, 'Alice');

        expect(container.read(setupProvider.notifier).isValid, isFalse);
      });
    });
  });
}
