import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_topic.dart';

abstract class PrayerTopicRepository {
  /// Get all topics for a user
  Future<Either<Failure, List<PrayerTopic>>> getTopics(String userId);

  /// Get topics by category
  Future<Either<Failure, List<PrayerTopic>>> getTopicsByCategory(
    String userId,
    String categoryId,
  );

  /// Get a single topic by ID
  Future<Either<Failure, PrayerTopic>> getTopicById(String id);

  /// Add a new topic
  Future<Either<Failure, PrayerTopic>> addTopic(PrayerTopic topic);

  /// Update an existing topic
  Future<Either<Failure, PrayerTopic>> updateTopic(PrayerTopic topic);

  /// Delete a topic (soft delete)
  Future<Either<Failure, void>> deleteTopic(String id);

  /// Increment prayer count
  Future<Either<Failure, void>> incrementPrayerCount(String id);

  /// Increment answered prayer count
  Future<Either<Failure, void>> incrementAnsweredCount(String id);
}
