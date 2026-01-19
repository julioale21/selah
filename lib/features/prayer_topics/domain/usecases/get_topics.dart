import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prayer_topic.dart';
import '../repositories/prayer_topic_repository.dart';

class GetTopics implements UseCase<List<PrayerTopic>, GetTopicsParams> {
  final PrayerTopicRepository repository;

  GetTopics(this.repository);

  @override
  Future<Either<Failure, List<PrayerTopic>>> call(GetTopicsParams params) {
    return repository.getTopics(params.userId);
  }
}

class GetTopicsParams {
  final String userId;

  const GetTopicsParams({required this.userId});
}
