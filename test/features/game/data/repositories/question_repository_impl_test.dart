import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/data/datasources/question_datasource.dart';
import 'package:mindclash/features/game/data/models/question_model.dart';
import 'package:mindclash/features/game/data/repositories/question_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockQuestionDataSource extends Mock implements QuestionDataSource {}

void main() {
  group('QuestionRepositoryImpl', () {
    late _MockQuestionDataSource primarySource;
    late _MockQuestionDataSource fallbackSource;

    const easyModel = QuestionModel(
      id: 'sci_001',
      text: 'Easy question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 0,
      difficulty: 'easy',
    );

    const mediumModel = QuestionModel(
      id: 'sci_002',
      text: 'Medium question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 1,
      difficulty: 'medium',
    );

    const hardModel = QuestionModel(
      id: 'sci_003',
      text: 'Hard question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 2,
      difficulty: 'hard',
    );

    final allModels = [easyModel, mediumModel, hardModel];

    setUp(() {
      primarySource = _MockQuestionDataSource();
      fallbackSource = _MockQuestionDataSource();
    });

    group('getQuestions', () {
      test('with single source returns mapped entities', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => allModels);
        final repo =
            QuestionRepositoryImpl(sources: [primarySource]);

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
        );

        expect(result, hasLength(3));
        expect(result[0].id, 'sci_001');
        expect(result[1].id, 'sci_002');
        expect(result[2].id, 'sci_003');
      });

      test('with multiple sources returns from first non-empty', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => allModels);
        when(() => fallbackSource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => [easyModel]);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
        );

        expect(result, hasLength(3));
        verifyNever(
          () => fallbackSource.getQuestions('science', locale: 'en'),
        );
      });

      test('skips empty source and uses fallback', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => []);
        when(() => fallbackSource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => [easyModel]);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
        );

        expect(result, hasLength(1));
        expect(result[0].id, 'sci_001');
      });

      test('with all sources empty returns empty list', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => []);
        when(() => fallbackSource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => []);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
        );

        expect(result, isEmpty);
      });

      test('filters by difficulty when specified', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => allModels);
        final repo =
            QuestionRepositoryImpl(sources: [primarySource]);

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
          difficulty: 'medium',
        );

        expect(result, hasLength(1));
        expect(result[0].difficulty, 'medium');
      });

      test('returns all when no difficulty filter', () async {
        when(() => primarySource.getQuestions('science', locale: 'en'))
            .thenAnswer((_) async => allModels);
        final repo =
            QuestionRepositoryImpl(sources: [primarySource]);

        final result = await repo.getQuestions(
          category: 'science',
          locale: 'en',
        );

        expect(result, hasLength(3));
      });

      test('passes locale through to source', () async {
        when(() => primarySource.getQuestions('science', locale: 'ar'))
            .thenAnswer((_) async => [easyModel]);
        final repo =
            QuestionRepositoryImpl(sources: [primarySource]);

        await repo.getQuestions(category: 'science', locale: 'ar');

        verify(
          () => primarySource.getQuestions('science', locale: 'ar'),
        ).called(1);
      });

      test(
        'does not try fallback when source has questions but '
        'none match difficulty',
        () async {
          // Primary has easy only, fallback has hard.
          // Filtering for hard should return [] — primary is
          // authoritative for the category once it returns non-empty.
          when(() => primarySource.getQuestions('science', locale: 'en'))
              .thenAnswer((_) async => [easyModel]);
          when(() => fallbackSource.getQuestions('science', locale: 'en'))
              .thenAnswer((_) async => [hardModel]);
          final repo = QuestionRepositoryImpl(
            sources: [primarySource, fallbackSource],
          );

          final result = await repo.getQuestions(
            category: 'science',
            locale: 'en',
            difficulty: 'hard',
          );

          expect(result, isEmpty);
          verifyNever(
            () => fallbackSource.getQuestions('science', locale: 'en'),
          );
        },
      );
    });

    group('getCategories', () {
      test('unions categories from all sources', () async {
        when(() => primarySource.getCategories())
            .thenAnswer((_) async => ['science']);
        when(() => fallbackSource.getCategories())
            .thenAnswer((_) async => ['history']);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getCategories();

        expect(result, containsAll(['history', 'science']));
      });

      test('deduplicates categories', () async {
        when(() => primarySource.getCategories())
            .thenAnswer((_) async => ['science']);
        when(() => fallbackSource.getCategories())
            .thenAnswer((_) async => ['science']);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getCategories();

        expect(result, hasLength(1));
        expect(result, ['science']);
      });

      test('sorts alphabetically', () async {
        when(() => primarySource.getCategories())
            .thenAnswer((_) async => ['science', 'art']);
        when(() => fallbackSource.getCategories())
            .thenAnswer((_) async => ['history']);
        final repo = QuestionRepositoryImpl(
          sources: [primarySource, fallbackSource],
        );

        final result = await repo.getCategories();

        expect(result, ['art', 'history', 'science']);
      });
    });
  });
}
