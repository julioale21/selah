import '../../domain/entities/prayer_topic.dart';

class PrayerTopicModel extends PrayerTopic {
  const PrayerTopicModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.categoryId,
    required super.iconName,
    super.prayerCount,
    super.answeredCount,
    super.isActive,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PrayerTopicModel.fromEntity(PrayerTopic topic) {
    return PrayerTopicModel(
      id: topic.id,
      userId: topic.userId,
      title: topic.title,
      description: topic.description,
      categoryId: topic.categoryId,
      iconName: topic.iconName,
      prayerCount: topic.prayerCount,
      answeredCount: topic.answeredCount,
      isActive: topic.isActive,
      sortOrder: topic.sortOrder,
      createdAt: topic.createdAt,
      updatedAt: topic.updatedAt,
    );
  }

  factory PrayerTopicModel.fromMap(Map<String, dynamic> map) {
    return PrayerTopicModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      categoryId: map['category_id'] as String?,
      iconName: map['icon_name'] as String,
      prayerCount: map['prayer_count'] as int? ?? 0,
      answeredCount: map['answered_count'] as int? ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'icon_name': iconName,
      'prayer_count': prayerCount,
      'answered_count': answeredCount,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PrayerTopicModel copyWithModel({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? categoryId,
    String? iconName,
    int? prayerCount,
    int? answeredCount,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrayerTopicModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      iconName: iconName ?? this.iconName,
      prayerCount: prayerCount ?? this.prayerCount,
      answeredCount: answeredCount ?? this.answeredCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
