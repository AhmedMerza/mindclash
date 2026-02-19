import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/repositories/question_repository.dart';
import 'package:mindclash/features/game/presentation/providers/question_repository_provider.dart';

void main() {
  group('questionRepositoryProvider', () {
    test('provides a QuestionRepository instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(questionRepositoryProvider);

      expect(repo, isA<QuestionRepository>());
    });

    test('returns the same instance on repeated reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo1 = container.read(questionRepositoryProvider);
      final repo2 = container.read(questionRepositoryProvider);

      expect(identical(repo1, repo2), isTrue);
    });
  });
}
