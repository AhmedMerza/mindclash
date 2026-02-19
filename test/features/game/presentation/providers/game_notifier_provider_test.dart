import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/repositories/question_repository.dart';
import 'package:mindclash/features/game/presentation/providers/game_notifier_provider.dart';
import 'package:mindclash/features/game/presentation/providers/play_phase.dart';
import 'package:mindclash/features/game/presentation/providers/question_repository_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

/// Generates [count] test questions.
List<Question> _testQuestions(int count) {
  return List.generate(
    count,
    (i) => Question(
      id: 'q_${i + 1}',
      text: 'Question ${i + 1}?',
      options: const ['A', 'B', 'C', 'D'],
      correctIndex: 0,
      difficulty: 'easy',
      score: 200,
    ),
  );
}

void _stubRepoWith(MockQuestionRepository repo, List<Question> questions) {
  when(
    () => repo.getQuestions(
      category: any(named: 'category'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => questions);
}

void main() {
  late ProviderContainer container;
  late MockQuestionRepository mockRepo;

  setUp(() {
    mockRepo = MockQuestionRepository();
    container = ProviderContainer(
      overrides: [
        questionRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GameNotifier', () {
    test('initial state is GameInitial with handOff phase', () {
      final state = container.read(gameProvider);

      expect(state.engineState, isA<GameInitial>());
      expect(state.playPhase, isA<PlayHandOff>());
    });

    group('startGame', () {
      test('transitions to playing state', () async {
        _stubRepoWith(mockRepo, _testQuestions(15));

        await container.read(gameProvider.notifier).startGame(
              teamNames: ['Alice', 'Bob'],
              locale: 'en',
              numberOfRounds: 3,
              selectedCategories: {'science'},
              randomCategory: false,
              randomDifficulty: false,
            );

        final state = container.read(gameProvider);
        expect(state.engineState, isA<GamePlaying>());
        expect(state.playPhase, isA<PlayHandOff>());
      });

      test('creates teams with correct names and IDs', () async {
        _stubRepoWith(mockRepo, _testQuestions(15));

        await container.read(gameProvider.notifier).startGame(
              teamNames: ['Alice', 'Bob'],
              locale: 'en',
              numberOfRounds: 3,
              selectedCategories: {'science'},
              randomCategory: false,
              randomDifficulty: false,
            );

        final state = container.read(gameProvider);
        final data = (state.engineState as GamePlaying).data;
        expect(data.teams.length, 2);
        expect(data.teams[0].name, 'Alice');
        expect(data.teams[0].id, 'p1');
        expect(data.teams[1].name, 'Bob');
        expect(data.teams[1].id, 'p2');
      });
    });

    group('turn flow', () {
      setUp(() async {
        _stubRepoWith(mockRepo, _testQuestions(15));

        await container.read(gameProvider.notifier).startGame(
              teamNames: ['Alice', 'Bob'],
              locale: 'en',
              numberOfRounds: 3,
              selectedCategories: {'science'},
              randomCategory: false,
              randomDifficulty: false,
            );
      });

      test('showQuestion transitions from handOff to answering', () {
        container.read(gameProvider.notifier).showQuestion();

        expect(container.read(gameProvider).playPhase, isA<PlayAnswering>());
      });

      test('answerQuestion with correct answer sets result phase', () {
        container.read(gameProvider.notifier)
          ..showQuestion()
          ..answerQuestion(0); // correctIndex is 0

        final state = container.read(gameProvider);
        final result = state.playPhase as PlayResult;
        expect(result.isCorrect, isTrue);
        expect(result.pointsAwarded, 200);
        expect(result.selectedIndex, 0);
      });

      test('answerQuestion with wrong answer sets result phase', () {
        container.read(gameProvider.notifier)
          ..showQuestion()
          ..answerQuestion(2); // wrong index

        final state = container.read(gameProvider);
        final result = state.playPhase as PlayResult;
        expect(result.isCorrect, isFalse);
        expect(result.pointsAwarded, 0);
        expect(result.selectedIndex, 2);
        expect(result.correctAnswerText, 'A');
      });

      test('skipQuestion sets result phase with 0 points', () {
        container.read(gameProvider.notifier)
          ..showQuestion()
          ..skipQuestion();

        final state = container.read(gameProvider);
        final result = state.playPhase as PlayResult;
        expect(result.isCorrect, isFalse);
        expect(result.pointsAwarded, 0);
        expect(result.selectedIndex, -1);
      });

      test('continueToNext goes back to handOff when still playing', () {
        container.read(gameProvider.notifier)
          ..showQuestion()
          ..answerQuestion(0)
          ..continueToNext();

        final state = container.read(gameProvider);
        expect(state.engineState, isA<GamePlaying>());
        expect(state.playPhase, isA<PlayHandOff>());
      });

      test('full round transitions to roundEnd', () {
        final notifier = container.read(gameProvider.notifier);

        // 2 players → questionsPerRound = 4 (adjusted from 5)
        for (var i = 0; i < 4; i++) {
          notifier
            ..showQuestion()
            ..answerQuestion(0)
            ..continueToNext();
        }

        expect(container.read(gameProvider).engineState, isA<GameRoundEnd>());
      });

      test('nextRound starts new round from handOff', () {
        final notifier = container.read(gameProvider.notifier);

        // 2 players → questionsPerRound = 4 (adjusted from 5)
        for (var i = 0; i < 4; i++) {
          notifier
            ..showQuestion()
            ..answerQuestion(0)
            ..continueToNext();
        }

        notifier.nextRound();

        final state = container.read(gameProvider);
        expect(state.engineState, isA<GamePlaying>());
        expect(state.playPhase, isA<PlayHandOff>());
        expect((state.engineState as GamePlaying).data.currentRound, 2);
      });
    });

    group('convenience getters', () {
      setUp(() async {
        _stubRepoWith(mockRepo, _testQuestions(15));

        await container.read(gameProvider.notifier).startGame(
              teamNames: ['Alice', 'Bob'],
              locale: 'en',
              numberOfRounds: 3,
              selectedCategories: {'science'},
              randomCategory: false,
              randomDifficulty: false,
            );
      });

      test('currentQuestion is cached after showQuestion', () {
        container.read(gameProvider.notifier).showQuestion();
        final question = container.read(gameProvider).currentQuestion;

        expect(question, isNotNull);
        expect(question!.id, startsWith('q_'));
        expect(question.options.length, 4);
      });

      test('currentTeam returns the first team', () {
        final team = container.read(gameProvider.notifier).currentTeam;

        expect(team, isNotNull);
        expect(team!.name, 'Alice');
      });

      test('sortedTeamsByScore returns teams sorted descending', () {
        final notifier = container.read(gameProvider.notifier)
          ..showQuestion()
          ..answerQuestion(0);

        final sorted = notifier.sortedTeamsByScore;
        expect(sorted.first.name, 'Alice');
        expect(sorted.first.score, 200);
        expect(sorted.last.name, 'Bob');
        expect(sorted.last.score, 0);
      });

      test('getters return null/empty in initial state', () {
        final freshContainer = ProviderContainer(
          overrides: [
            questionRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(freshContainer.dispose);

        final state = freshContainer.read(gameProvider);
        final notifier = freshContainer.read(gameProvider.notifier);

        expect(state.currentQuestion, isNull);
        expect(notifier.currentTeam, isNull);
        expect(notifier.sortedTeamsByScore, isEmpty);
      });
    });

    group('pause/resume/end', () {
      setUp(() async {
        _stubRepoWith(mockRepo, _testQuestions(15));

        await container.read(gameProvider.notifier).startGame(
              teamNames: ['Alice', 'Bob'],
              locale: 'en',
              numberOfRounds: 3,
              selectedCategories: {'science'},
              randomCategory: false,
              randomDifficulty: false,
            );
      });

      test('pauseGame transitions to paused', () {
        container.read(gameProvider.notifier).pauseGame();

        expect(container.read(gameProvider).engineState, isA<GamePaused>());
      });

      test('resumeGame transitions back to playing', () {
        container.read(gameProvider.notifier)
          ..pauseGame()
          ..resumeGame();

        expect(container.read(gameProvider).engineState, isA<GamePlaying>());
      });

      test('endGame transitions to finished', () {
        container.read(gameProvider.notifier).endGame();

        expect(
          container.read(gameProvider).engineState,
          isA<GameFinished>(),
        );
      });
    });

    test('full game flow through all 3 rounds', () async {
      _stubRepoWith(mockRepo, _testQuestions(15));

      final notifier = container.read(gameProvider.notifier);
      await notifier.startGame(
        teamNames: ['Alice', 'Bob'],
        locale: 'en',
        numberOfRounds: 3,
        selectedCategories: {'science'},
        randomCategory: true,
        randomDifficulty: true,
      );

      // 2 players → questionsPerRound = 4 (adjusted from 5)
      for (var round = 0; round < 3; round++) {
        for (var q = 0; q < 4; q++) {
          notifier
            ..showQuestion()
            ..answerQuestion(0)
            ..continueToNext();
        }

        if (round < 2) {
          expect(
            container.read(gameProvider).engineState,
            isA<GameRoundEnd>(),
          );
          notifier.nextRound();
        }
      }

      expect(
        container.read(gameProvider).engineState,
        isA<GameRoundEnd>(),
      );

      notifier.endGame();
      expect(
        container.read(gameProvider).engineState,
        isA<GameFinished>(),
      );

      final sorted = notifier.sortedTeamsByScore;
      expect(sorted.first.score, greaterThan(0));
    });

    group('question selection', () {
      test('selects questions and tracks used IDs', () async {
        _stubRepoWith(mockRepo, _testQuestions(10));

        await container.read(gameProvider.notifier).startGame(
          teamNames: ['Alice', 'Bob'],
          locale: 'en',
          numberOfRounds: 1,
          selectedCategories: {'science'},
          randomCategory: true,
          randomDifficulty: true,
        );

        final notifier = container.read(gameProvider.notifier);

        // Show first question
        notifier.showQuestion();
        final state1 = container.read(gameProvider);
        final q1 = state1.currentQuestion;
        expect(q1, isNotNull);
        expect(state1.usedQuestionIds, isEmpty); // Not marked used until answered

        // Answer first question
        notifier.answerQuestion(0);
        final state2 = container.read(gameProvider);
        expect(state2.usedQuestionIds, contains(q1!.id));

        // Continue and show second question
        notifier.continueToNext();
        notifier.showQuestion();
        final state3 = container.read(gameProvider);
        final q2 = state3.currentQuestion;
        expect(q2, isNotNull);
        expect(q2!.id, isNot(q1.id)); // Different question

        // Answer second question
        notifier.answerQuestion(0);
        final state4 = container.read(gameProvider);
        expect(state4.usedQuestionIds, containsAll([q1.id, q2.id]));
      });

      test('preference methods update state correctly', () async {
        _stubRepoWith(mockRepo, _testQuestions(10));

        await container.read(gameProvider.notifier).startGame(
          teamNames: ['Alice', 'Bob'],
          locale: 'en',
          numberOfRounds: 1,
          selectedCategories: {'science'},
          randomCategory: false,
          randomDifficulty: false,
        );

        final notifier = container.read(gameProvider.notifier);

        // Set category preference
        notifier.setCategoryPreference('history');
        expect(
          container.read(gameProvider).nextQuestionPreference?.category,
          'history',
        );

        // Set difficulty preference
        notifier.setDifficultyPreference('hard');
        expect(
          container.read(gameProvider).nextQuestionPreference?.difficulty,
          'hard',
        );

        // Randomize category (clears preference)
        notifier.randomizeCategory();
        expect(
          container.read(gameProvider).nextQuestionPreference?.category,
          isNull,
        );

        // Randomize difficulty (clears preference)
        notifier.randomizeDifficulty();
        expect(
          container.read(gameProvider).nextQuestionPreference?.difficulty,
          isNull,
        );
      });

      test('toggle methods switch random modes mid-game', () async {
        _stubRepoWith(mockRepo, _testQuestions(10));

        await container.read(gameProvider.notifier).startGame(
          teamNames: ['Alice', 'Bob'],
          locale: 'en',
          numberOfRounds: 1,
          selectedCategories: {'science'},
          randomCategory: false,
          randomDifficulty: false,
        );

        final notifier = container.read(gameProvider.notifier);

        // Initially NOT random (new default)
        var data = (container.read(gameProvider).engineState as GamePlaying).data;
        expect(data.config.randomCategory, isFalse);
        expect(data.config.randomDifficulty, isFalse);

        // Toggle on
        notifier.toggleRandomCategory();
        data = (container.read(gameProvider).engineState as GamePlaying).data;
        expect(data.config.randomCategory, isTrue);

        notifier.toggleRandomDifficulty();
        data = (container.read(gameProvider).engineState as GamePlaying).data;
        expect(data.config.randomDifficulty, isTrue);

        // Toggle back off
        notifier.toggleRandomCategory();
        data = (container.read(gameProvider).engineState as GamePlaying).data;
        expect(data.config.randomCategory, isFalse);

        notifier.toggleRandomDifficulty();
        data = (container.read(gameProvider).engineState as GamePlaying).data;
        expect(data.config.randomDifficulty, isFalse);
      });

      test('currentQuestion cleared after continueToNext', () async {
        _stubRepoWith(mockRepo, _testQuestions(10));

        await container.read(gameProvider.notifier).startGame(
          teamNames: ['Alice', 'Bob'],
          locale: 'en',
          numberOfRounds: 1,
          selectedCategories: {'science'},
          randomCategory: false,
          randomDifficulty: false,
        );

        final notifier = container.read(gameProvider.notifier);

        // Show and answer question
        notifier
          ..showQuestion()
          ..answerQuestion(0);

        // Question should still be cached during result phase
        expect(container.read(gameProvider).currentQuestion, isNotNull);

        // Continue to next - question should be cleared
        notifier.continueToNext();
        expect(container.read(gameProvider).currentQuestion, isNull);
        expect(container.read(gameProvider).nextQuestionPreference, isNull);
      });
    });
  });
}
