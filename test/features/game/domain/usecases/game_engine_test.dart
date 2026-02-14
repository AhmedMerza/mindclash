import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/features/game/domain/entities/game_action.dart';
import 'package:mindclash/features/game/domain/entities/game_config.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/domain/entities/game_state.dart';
import 'package:mindclash/features/game/domain/entities/player.dart';
import 'package:mindclash/features/game/domain/entities/question.dart';
import 'package:mindclash/features/game/domain/usecases/game_engine.dart';

void main() {
  const engine = GameEngine();

  // -- Shared fixtures -------------------------------------------------------

  const alice = Player(id: 'p1', name: 'Alice');
  const bob = Player(id: 'p2', name: 'Bob');
  const players = [alice, bob];

  const easyQuestion = Question(
    id: 'q1',
    text: 'Easy?',
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 0,
    difficulty: 'easy',
    score: 200,
  );

  const mediumQuestion = Question(
    id: 'q2',
    text: 'Medium?',
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 1,
    difficulty: 'medium',
    score: 400,
  );

  const hardQuestion = Question(
    id: 'q3',
    text: 'Hard?',
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 2,
    difficulty: 'hard',
    score: 600,
  );

  const extraQuestion = Question(
    id: 'q4',
    text: 'Extra?',
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 3,
    difficulty: 'easy',
    score: 200,
  );

  // 2 rounds x 2 questions = 4 questions needed
  const testConfig = GameConfig(numberOfRounds: 2, questionsPerRound: 2);
  const testQuestions = [
    easyQuestion,
    mediumQuestion,
    hardQuestion,
    extraQuestion,
  ];

  // -- Helpers ---------------------------------------------------------------

  GameState startGame({
    List<Player> p = players,
    GameConfig c = testConfig,
    List<Question> q = testQuestions,
  }) {
    return engine.process(
      const GameState.initial(),
      GameAction.startGame(players: p, config: c, questions: q),
    );
  }

  GameData playingData(GameState state) {
    return (state as GamePlaying).data;
  }

  GameData pausedData(GameState state) {
    return (state as GamePaused).data;
  }

  GameData roundEndData(GameState state) {
    return (state as GameRoundEnd).data;
  }

  GameData finishedData(GameState state) {
    return (state as GameFinished).data;
  }

  // ==========================================================================
  // StartGame
  // ==========================================================================

  group('StartGame', () {
    test('creates playing state with correct initial data', () {
      final state = startGame();
      final data = playingData(state);

      expect(state, isA<GamePlaying>());
      expect(data.players, equals(players));
      expect(data.questions, equals(testQuestions));
      expect(data.config, equals(testConfig));
      expect(data.currentPlayerIndex, 0);
      expect(data.currentQuestionIndex, 0);
      expect(data.currentRound, 1);
    });

    test('preserves player order', () {
      const reversed = [bob, alice];
      final state = startGame(p: reversed);
      final data = playingData(state);

      expect(data.players[0], bob);
      expect(data.players[1], alice);
    });
  });

  // ==========================================================================
  // AnswerQuestion — scoring
  // ==========================================================================

  group('AnswerQuestion — scoring', () {
    test('correct easy answer awards 200 points', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 0), // correct for easy
      );

      final data = playingData(next);
      expect(data.players[0].score, 200);
    });

    test('correct medium answer awards 400 points', () {
      // Advance to question index 1 (medium question) by answering q0
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      // Now Bob answers medium question correctly (correctIndex=1)
      final afterQ1 = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1),
      );

      final data = roundEndData(afterQ1);
      expect(data.players[1].score, 400); // Bob got 400
    });

    test('correct hard answer awards 600 points', () {
      // Set up a config where hard question is first
      const config = GameConfig(numberOfRounds: 1, questionsPerRound: 1);
      final state = engine.process(
        const GameState.initial(),
        const GameAction.startGame(
          players: players,
          config: config,
          questions: [hardQuestion],
        ),
      );

      final next = engine.process(
        state,
        const GameAction.answerQuestion(selectedIndex: 2), // correct for hard
      );

      final data = roundEndData(next);
      expect(data.players[0].score, 600);
    });

    test('custom score question awards its score value', () {
      const expertQuestion = Question(
        id: 'q_expert',
        text: 'Expert?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'expert',
        score: 1000,
      );
      const config = GameConfig(numberOfRounds: 1, questionsPerRound: 1);
      final state = engine.process(
        const GameState.initial(),
        const GameAction.startGame(
          players: players,
          config: config,
          questions: [expertQuestion],
        ),
      );

      final next = engine.process(
        state,
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      final data = roundEndData(next);
      expect(data.players[0].score, 1000);
    });

    test('wrong answer awards 0 points', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 3), // wrong for easy
      );

      final data = playingData(next);
      expect(data.players[0].score, 0);
    });

    test('out-of-range selectedIndex awards 0 points', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 99),
      );

      final data = playingData(next);
      expect(data.players[0].score, 0);
    });
  });

  // ==========================================================================
  // AnswerQuestion — turn rotation
  // ==========================================================================

  group('AnswerQuestion — turn rotation', () {
    test('advances to next player', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      final data = playingData(next);
      expect(data.currentPlayerIndex, 1); // Alice->Bob
    });

    test('player index wraps around to 0', () {
      // After Alice answers (index becomes 1=Bob), Bob answers (wraps to 0)
      final afterAlice = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final afterBob = engine.process(
        afterAlice,
        const GameAction.answerQuestion(selectedIndex: 1),
      );

      // Round ends after 2 questions, but player index should wrap
      final data = roundEndData(afterBob);
      expect(data.currentPlayerIndex, 0); // wrapped back
    });

    test('advances question index by 1', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      final data = playingData(next);
      expect(data.currentQuestionIndex, 1);
    });

    test('only current player score changes', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.answerQuestion(selectedIndex: 0), // Alice correct
      );

      final data = playingData(next);
      expect(data.players[0].score, 200); // Alice scored
      expect(data.players[1].score, 0); // Bob unchanged
    });
  });

  // ==========================================================================
  // SkipQuestion
  // ==========================================================================

  group('SkipQuestion', () {
    test('scores 0 points for all players', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.skipQuestion(),
      );

      final data = playingData(next);
      expect(data.players[0].score, 0);
      expect(data.players[1].score, 0);
    });

    test('advances player and question indices like answer', () {
      final playing = startGame();
      final next = engine.process(
        playing,
        const GameAction.skipQuestion(),
      );

      final data = playingData(next);
      expect(data.currentPlayerIndex, 1);
      expect(data.currentQuestionIndex, 1);
    });
  });

  // ==========================================================================
  // Round transitions
  // ==========================================================================

  group('Round transitions', () {
    test('answer triggers roundEnd when question limit reached', () {
      // Answer 2 questions (questionsPerRound=2)
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final afterQ1 = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1),
      );

      expect(afterQ1, isA<GameRoundEnd>());
    });

    test('skip triggers roundEnd when question limit reached', () {
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.skipQuestion(),
      );
      final afterQ1 = engine.process(
        afterQ0,
        const GameAction.skipQuestion(),
      );

      expect(afterQ1, isA<GameRoundEnd>());
    });

    test('nextRound advances round and resets indices to 0', () {
      // Complete round 1
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final roundEnd = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1),
      );

      final nextRound = engine.process(
        roundEnd,
        const GameAction.nextRound(),
      );

      expect(nextRound, isA<GamePlaying>());
      final data = playingData(nextRound);
      expect(data.currentRound, 2);
      expect(data.currentQuestionIndex, 0);
      expect(data.currentPlayerIndex, 0);
    });

    test('nextRound on last round transitions to finished', () {
      // Complete round 1
      final afterR1Q0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final roundEnd1 = engine.process(
        afterR1Q0,
        const GameAction.answerQuestion(selectedIndex: 1),
      );
      // Start round 2
      final round2 = engine.process(
        roundEnd1,
        const GameAction.nextRound(),
      );
      // Complete round 2
      final afterR2Q0 = engine.process(
        round2,
        const GameAction.answerQuestion(selectedIndex: 2),
      );
      final roundEnd2 = engine.process(
        afterR2Q0,
        const GameAction.answerQuestion(selectedIndex: 3),
      );
      // Try next round (but we're at max)
      final finished = engine.process(
        roundEnd2,
        const GameAction.nextRound(),
      );

      expect(finished, isA<GameFinished>());
    });

    test('round end preserves player scores', () {
      // Alice answers correctly, then round ends
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0), // +200
      );
      final roundEnd = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1), // Bob +400
      );

      final data = roundEndData(roundEnd);
      expect(data.players[0].score, 200);
      expect(data.players[1].score, 400);
    });
  });

  // ==========================================================================
  // Pause and resume
  // ==========================================================================

  group('Pause and resume', () {
    test('pauseGame transitions playing to paused', () {
      final playing = startGame();
      final paused = engine.process(
        playing,
        const GameAction.pauseGame(),
      );

      expect(paused, isA<GamePaused>());
    });

    test('pause preserves all data exactly', () {
      // Answer a question first so data is non-trivial
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final playingBefore = playingData(afterQ0);

      final paused = engine.process(
        afterQ0,
        const GameAction.pauseGame(),
      );

      expect(pausedData(paused), playingBefore);
    });

    test('resumeGame transitions paused to playing', () {
      final paused = engine.process(
        startGame(),
        const GameAction.pauseGame(),
      );
      final resumed = engine.process(
        paused,
        const GameAction.resumeGame(),
      );

      expect(resumed, isA<GamePlaying>());
    });

    test('resume preserves all data exactly', () {
      final playing = startGame();
      final originalData = playingData(playing);

      final paused = engine.process(
        playing,
        const GameAction.pauseGame(),
      );
      final resumed = engine.process(
        paused,
        const GameAction.resumeGame(),
      );

      expect(playingData(resumed), originalData);
    });

    test('pause then resume round-trip preserves state', () {
      // Build non-trivial state: answer a question
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      final paused = engine.process(
        afterQ0,
        const GameAction.pauseGame(),
      );
      final resumed = engine.process(
        paused,
        const GameAction.resumeGame(),
      );

      // Should be identical to before pause
      expect(resumed, afterQ0);
    });
  });

  // ==========================================================================
  // EndGame
  // ==========================================================================

  group('EndGame', () {
    test('from playing transitions to finished', () {
      final playing = startGame();
      final finished = engine.process(
        playing,
        const GameAction.endGame(),
      );

      expect(finished, isA<GameFinished>());
    });

    test('from paused transitions to finished', () {
      final paused = engine.process(
        startGame(),
        const GameAction.pauseGame(),
      );
      final finished = engine.process(
        paused,
        const GameAction.endGame(),
      );

      expect(finished, isA<GameFinished>());
    });

    test('from roundEnd transitions to finished', () {
      // Complete a round
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final roundEnd = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1),
      );

      final finished = engine.process(
        roundEnd,
        const GameAction.endGame(),
      );

      expect(finished, isA<GameFinished>());
    });

    test('preserves final scores', () {
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0), // Alice +200
      );
      final finished = engine.process(
        afterQ0,
        const GameAction.endGame(),
      );

      final data = finishedData(finished);
      expect(data.players[0].score, 200);
      expect(data.players[1].score, 0);
    });
  });

  // ==========================================================================
  // Invalid transitions
  // ==========================================================================

  group('Invalid transitions', () {
    group('from initial', () {
      const initial = GameState.initial();

      test('answerQuestion throws StateError', () {
        expect(
          () => engine.process(
            initial,
            const GameAction.answerQuestion(selectedIndex: 0),
          ),
          throwsStateError,
        );
      });

      test('skipQuestion throws StateError', () {
        expect(
          () => engine.process(initial, const GameAction.skipQuestion()),
          throwsStateError,
        );
      });

      test('nextRound throws StateError', () {
        expect(
          () => engine.process(initial, const GameAction.nextRound()),
          throwsStateError,
        );
      });

      test('pauseGame throws StateError', () {
        expect(
          () => engine.process(initial, const GameAction.pauseGame()),
          throwsStateError,
        );
      });

      test('resumeGame throws StateError', () {
        expect(
          () => engine.process(initial, const GameAction.resumeGame()),
          throwsStateError,
        );
      });

      test('endGame throws StateError', () {
        expect(
          () => engine.process(initial, const GameAction.endGame()),
          throwsStateError,
        );
      });
    });

    group('from playing', () {
      test('startGame throws StateError', () {
        expect(
          () => engine.process(
            startGame(),
            const GameAction.startGame(
              players: players,
              config: testConfig,
              questions: testQuestions,
            ),
          ),
          throwsStateError,
        );
      });

      test('nextRound throws StateError', () {
        expect(
          () => engine.process(startGame(), const GameAction.nextRound()),
          throwsStateError,
        );
      });

      test('resumeGame throws StateError', () {
        expect(
          () => engine.process(startGame(), const GameAction.resumeGame()),
          throwsStateError,
        );
      });
    });

    group('from paused', () {
      late GameState paused;

      setUp(() {
        paused = engine.process(startGame(), const GameAction.pauseGame());
      });

      test('startGame throws StateError', () {
        expect(
          () => engine.process(
            paused,
            const GameAction.startGame(
              players: players,
              config: testConfig,
              questions: testQuestions,
            ),
          ),
          throwsStateError,
        );
      });

      test('answerQuestion throws StateError', () {
        expect(
          () => engine.process(
            paused,
            const GameAction.answerQuestion(selectedIndex: 0),
          ),
          throwsStateError,
        );
      });

      test('skipQuestion throws StateError', () {
        expect(
          () => engine.process(paused, const GameAction.skipQuestion()),
          throwsStateError,
        );
      });

      test('nextRound throws StateError', () {
        expect(
          () => engine.process(paused, const GameAction.nextRound()),
          throwsStateError,
        );
      });

      test('pauseGame throws StateError', () {
        expect(
          () => engine.process(paused, const GameAction.pauseGame()),
          throwsStateError,
        );
      });
    });

    group('from roundEnd', () {
      late GameState roundEnd;

      setUp(() {
        final afterQ0 = engine.process(
          startGame(),
          const GameAction.answerQuestion(selectedIndex: 0),
        );
        roundEnd = engine.process(
          afterQ0,
          const GameAction.answerQuestion(selectedIndex: 1),
        );
      });

      test('startGame throws StateError', () {
        expect(
          () => engine.process(
            roundEnd,
            const GameAction.startGame(
              players: players,
              config: testConfig,
              questions: testQuestions,
            ),
          ),
          throwsStateError,
        );
      });

      test('answerQuestion throws StateError', () {
        expect(
          () => engine.process(
            roundEnd,
            const GameAction.answerQuestion(selectedIndex: 0),
          ),
          throwsStateError,
        );
      });

      test('skipQuestion throws StateError', () {
        expect(
          () => engine.process(roundEnd, const GameAction.skipQuestion()),
          throwsStateError,
        );
      });

      test('pauseGame throws StateError', () {
        expect(
          () => engine.process(roundEnd, const GameAction.pauseGame()),
          throwsStateError,
        );
      });

      test('resumeGame throws StateError', () {
        expect(
          () => engine.process(roundEnd, const GameAction.resumeGame()),
          throwsStateError,
        );
      });
    });

    group('from finished', () {
      late GameState finished;

      setUp(() {
        finished = engine.process(startGame(), const GameAction.endGame());
      });

      test('startGame throws StateError', () {
        expect(
          () => engine.process(
            finished,
            const GameAction.startGame(
              players: players,
              config: testConfig,
              questions: testQuestions,
            ),
          ),
          throwsStateError,
        );
      });

      test('answerQuestion throws StateError', () {
        expect(
          () => engine.process(
            finished,
            const GameAction.answerQuestion(selectedIndex: 0),
          ),
          throwsStateError,
        );
      });

      test('skipQuestion throws StateError', () {
        expect(
          () => engine.process(finished, const GameAction.skipQuestion()),
          throwsStateError,
        );
      });

      test('nextRound throws StateError', () {
        expect(
          () => engine.process(finished, const GameAction.nextRound()),
          throwsStateError,
        );
      });

      test('pauseGame throws StateError', () {
        expect(
          () => engine.process(finished, const GameAction.pauseGame()),
          throwsStateError,
        );
      });

      test('resumeGame throws StateError', () {
        expect(
          () => engine.process(finished, const GameAction.resumeGame()),
          throwsStateError,
        );
      });

      test('endGame throws StateError', () {
        expect(
          () => engine.process(finished, const GameAction.endGame()),
          throwsStateError,
        );
      });
    });
  });

  // ==========================================================================
  // Edge cases
  // ==========================================================================

  group('Edge cases', () {
    test('single player rotates back to self', () {
      const soloConfig = GameConfig(numberOfRounds: 1, questionsPerRound: 2);
      final state = engine.process(
        const GameState.initial(),
        const GameAction.startGame(
          players: [alice],
          config: soloConfig,
          questions: testQuestions,
        ),
      );

      final afterQ0 = engine.process(
        state,
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      final data = playingData(afterQ0);
      expect(data.currentPlayerIndex, 0); // wraps to self
    });

    test('single question per round triggers immediate round end', () {
      const config = GameConfig(numberOfRounds: 2, questionsPerRound: 1);
      final state = engine.process(
        const GameState.initial(),
        const GameAction.startGame(
          players: players,
          config: config,
          questions: [easyQuestion, mediumQuestion],
        ),
      );

      final afterQ0 = engine.process(
        state,
        const GameAction.answerQuestion(selectedIndex: 0),
      );

      expect(afterQ0, isA<GameRoundEnd>());
    });

    test('single round finishes after one round', () {
      const config = GameConfig(numberOfRounds: 1, questionsPerRound: 1);
      final state = engine.process(
        const GameState.initial(),
        const GameAction.startGame(
          players: players,
          config: config,
          questions: [easyQuestion],
        ),
      );

      final roundEnd = engine.process(
        state,
        const GameAction.answerQuestion(selectedIndex: 0),
      );
      final finished = engine.process(
        roundEnd,
        const GameAction.nextRound(),
      );

      expect(finished, isA<GameFinished>());
    });

    test('cumulative scoring across multiple answers', () {
      // Alice answers q0 correctly (+200), round ends, next round,
      // Alice answers q2 correctly (+600)
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0), // Alice +200
      );
      final roundEnd = engine.process(
        afterQ0,
        const GameAction.skipQuestion(), // Bob skips
      );
      final round2 = engine.process(
        roundEnd,
        const GameAction.nextRound(),
      );
      // Round 2, question index 0 -> global index 2 (hard, correctIndex=2)
      final afterR2Q0 = engine.process(
        round2,
        const GameAction.answerQuestion(selectedIndex: 2), // Alice +600
      );

      final data = playingData(afterR2Q0);
      expect(data.players[0].score, 800); // 200 + 600
    });

    test('multiple players accumulate scores independently', () {
      // Alice answers q0 correctly, Bob answers q1 correctly
      final afterQ0 = engine.process(
        startGame(),
        const GameAction.answerQuestion(selectedIndex: 0), // Alice +200 (easy)
      );
      final afterQ1 = engine.process(
        afterQ0,
        const GameAction.answerQuestion(selectedIndex: 1), // Bob +400 (medium)
      );

      final data = roundEndData(afterQ1);
      expect(data.players[0].score, 200); // Alice
      expect(data.players[1].score, 400); // Bob
    });

    test('global question indexing uses correct questions per round', () {
      // Round 1 uses questions 0,1. Round 2 uses questions 2,3.
      final afterR1Q0 = engine.process(
        startGame(),
        const GameAction.skipQuestion(),
      );
      final roundEnd1 = engine.process(
        afterR1Q0,
        const GameAction.skipQuestion(),
      );
      final round2 = engine.process(
        roundEnd1,
        const GameAction.nextRound(),
      );

      // Round 2, question 0 globally = index 2 (hardQuestion, correctIndex=2)
      final afterR2Q0 = engine.process(
        round2,
        const GameAction.answerQuestion(selectedIndex: 2), // correct for hard
      );

      final data = playingData(afterR2Q0);
      expect(data.players[0].score, 600); // hard question = 600
    });
  });
}
