import 'package:equatable/equatable.dart';

class PrayerTopic extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? categoryId;
  final String iconName;
  final int prayerCount;
  final int answeredCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PrayerTopic({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.categoryId,
    required this.iconName,
    this.prayerCount = 0,
    this.answeredCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  PrayerTopic copyWith({
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
    return PrayerTopic(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        categoryId,
        iconName,
        prayerCount,
        answeredCount,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
