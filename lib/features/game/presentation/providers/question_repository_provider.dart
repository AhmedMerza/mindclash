import 'package:mindclash/features/game/data/datasources/local_question_datasource.dart';
import 'package:mindclash/features/game/data/repositories/question_repository_impl.dart';
import 'package:mindclash/features/game/domain/repositories/question_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_repository_provider.g.dart';

/// Provides the [QuestionRepository] backed by local JSON assets.
@riverpod
QuestionRepository questionRepository(Ref ref) {
  return const QuestionRepositoryImpl(
    sources: [LocalQuestionDataSource()],
  );
}
