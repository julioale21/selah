import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prayer_topic.dart';
import '../repositories/prayer_topic_repository.dart';

class UpdateTopic implements UseCase<PrayerTopic, PrayerTopic> {
  final PrayerTopicRepository repository;

  UpdateTopic(this.repository);

  @override
  Future<Either<Failure, PrayerTopic>> call(PrayerTopic topic) {
    final updatedTopic = topic.copyWith(updatedAt: DateTime.now());
    return repository.updateTopic(updatedTopic);
  }
}
