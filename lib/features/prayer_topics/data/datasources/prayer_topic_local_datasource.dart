import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/prayer_topic_model.dart';

abstract class PrayerTopicLocalDataSource {
  Future<List<PrayerTopicModel>> getTopics(String userId);
  Future<List<PrayerTopicModel>> getTopicsByCategory(String userId, String categoryId);
  Future<PrayerTopicModel> getTopicById(String id);
  Future<PrayerTopicModel> addTopic(PrayerTopicModel topic);
  Future<PrayerTopicModel> updateTopic(PrayerTopicModel topic);
  Future<void> deleteTopic(String id);
  Future<void> incrementPrayerCount(String id);
  Future<void> incrementAnsweredCount(String id);
  Future<void> reorderTopics(List<PrayerTopicModel> topics);
}

class PrayerTopicLocalDataSourceImpl implements PrayerTopicLocalDataSource {
  final DatabaseHelper databaseHelper;

  PrayerTopicLocalDataSourceImpl({required this.databaseHelper});

  static const String _tableName = 'prayer_topics';

  @override
  Future<List<PrayerTopicModel>> getTopics(String userId) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ? AND is_active = ?',
        whereArgs: [userId, 1],
        orderBy: 'sort_order ASC, created_at DESC',
      );
      return results.map((map) => PrayerTopicModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Error al obtener temas: $e');
    }
  }

  @override
  Future<List<PrayerTopicModel>> getTopicsByCategory(
    String userId,
    String categoryId,
  ) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ? AND category_id = ? AND is_active = ?',
        whereArgs: [userId, categoryId, 1],
        orderBy: 'sort_order ASC, created_at DESC',
      );
      return results.map((map) => PrayerTopicModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Error al obtener temas por categoría: $e');
    }
  }

  @override
  Future<PrayerTopicModel> getTopicById(String id) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        throw NotFoundException('Tema no encontrado');
      }

      return PrayerTopicModel.fromMap(results.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Error al obtener tema: $e');
    }
  }

  @override
  Future<PrayerTopicModel> addTopic(PrayerTopicModel topic) async {
    try {
      await databaseHelper.insert(_tableName, topic.toMap());
      return topic;
    } catch (e) {
      throw DatabaseException('Error al agregar tema: $e');
    }
  }

  @override
  Future<PrayerTopicModel> updateTopic(PrayerTopicModel topic) async {
    try {
      final updatedTopic = topic.copyWithModel(
        updatedAt: DateTime.now(),
      );

      await databaseHelper.update(
        _tableName,
        updatedTopic.toMap(),
        where: 'id = ?',
        whereArgs: [topic.id],
      );
      return updatedTopic;
    } catch (e) {
      throw DatabaseException('Error al actualizar tema: $e');
    }
  }

  @override
  Future<void> deleteTopic(String id) async {
    try {
      // Soft delete
      await databaseHelper.update(
        _tableName,
        {
          'is_active': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Error al eliminar tema: $e');
    }
  }

  @override
  Future<void> incrementPrayerCount(String id) async {
    try {
      final topic = await getTopicById(id);
      await databaseHelper.update(
        _tableName,
        {
          'prayer_count': topic.prayerCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Error al incrementar contador: $e');
    }
  }

  @override
  Future<void> incrementAnsweredCount(String id) async {
    try {
      final topic = await getTopicById(id);
      await databaseHelper.update(
        _tableName,
        {
          'answered_count': topic.answeredCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Error al incrementar respuestas: $e');
    }
  }

  @override
  Future<void> reorderTopics(List<PrayerTopicModel> topics) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (int i = 0; i < topics.length; i++) {
        await databaseHelper.update(
          _tableName,
          {
            'sort_order': i,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [topics[i].id],
        );
      }
    } catch (e) {
      throw DatabaseException('Error al reordenar temas: $e');
    }
  }
}
