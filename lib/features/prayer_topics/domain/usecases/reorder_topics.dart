import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_topic.dart';
import '../repositories/prayer_topic_repository.dart';

class ReorderTopics {
  final PrayerTopicRepository repository;

  ReorderTopics(this.repository);

  Future<Either<Failure, void>> call(List<PrayerTopic> topics) async {
    return await repository.reorderTopics(topics);
  }
}
