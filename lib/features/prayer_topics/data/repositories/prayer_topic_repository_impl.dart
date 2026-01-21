import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_topic.dart';
import '../../domain/repositories/prayer_topic_repository.dart';
import '../datasources/prayer_topic_local_datasource.dart';
import '../models/prayer_topic_model.dart';

class PrayerTopicRepositoryImpl implements PrayerTopicRepository {
  final PrayerTopicLocalDataSource localDataSource;

  PrayerTopicRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PrayerTopic>>> getTopics(String userId) async {
    try {
      final topics = await localDataSource.getTopics(userId);
      return Right(topics);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTopic>>> getTopicsByCategory(
    String userId,
    String categoryId,
  ) async {
    try {
      final topics = await localDataSource.getTopicsByCategory(userId, categoryId);
      return Right(topics);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerTopic>> getTopicById(String id) async {
    try {
      final topic = await localDataSource.getTopicById(id);
      return Right(topic);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerTopic>> addTopic(PrayerTopic topic) async {
    try {
      final model = PrayerTopicModel.fromEntity(topic);
      final result = await localDataSource.addTopic(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerTopic>> updateTopic(PrayerTopic topic) async {
    try {
      final model = PrayerTopicModel.fromEntity(topic);
      final result = await localDataSource.updateTopic(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTopic(String id) async {
    try {
      await localDataSource.deleteTopic(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> incrementPrayerCount(String id) async {
    try {
      await localDataSource.incrementPrayerCount(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> incrementAnsweredCount(String id) async {
    try {
      await localDataSource.incrementAnsweredCount(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderTopics(List<PrayerTopic> topics) async {
    try {
      final models = topics.map((t) => PrayerTopicModel.fromEntity(t)).toList();
      await localDataSource.reorderTopics(models);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
