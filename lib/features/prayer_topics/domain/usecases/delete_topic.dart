import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/prayer_topic_repository.dart';

class DeleteTopic implements UseCase<void, String> {
  final PrayerTopicRepository repository;

  DeleteTopic(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTopic(id);
  }
}
