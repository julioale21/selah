import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prayer_topic.dart';
import '../repositories/prayer_topic_repository.dart';

class AddTopic implements UseCase<PrayerTopic, AddTopicParams> {
  final PrayerTopicRepository repository;
  static const _uuid = Uuid();

  AddTopic(this.repository);

  @override
  Future<Either<Failure, PrayerTopic>> call(AddTopicParams params) {
    final now = DateTime.now();
    final topic = PrayerTopic(
      id: _uuid.v4(),
      userId: params.userId,
      title: params.title,
      description: params.description,
      categoryId: params.categoryId,
      iconName: params.iconName,
      createdAt: now,
      updatedAt: now,
    );
    return repository.addTopic(topic);
  }
}

class AddTopicParams {
  final String userId;
  final String title;
  final String? description;
  final String? categoryId;
  final String iconName;

  const AddTopicParams({
    required this.userId,
    required this.title,
    this.description,
    this.categoryId,
    required this.iconName,
  });
}
