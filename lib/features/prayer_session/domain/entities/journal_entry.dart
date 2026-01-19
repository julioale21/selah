import 'package:equatable/equatable.dart';

enum JournalEntryType { prayer, reflection, gratitude, testimony }

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String? sessionId;
  final String? topicId;
  final String content;
  final String? actsStep;
  final JournalEntryType type;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    this.sessionId,
    this.topicId,
    required this.content,
    this.actsStep,
    this.type = JournalEntryType.prayer,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? topicId,
    String? content,
    String? actsStep,
    JournalEntryType? type,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      topicId: topicId ?? this.topicId,
      content: content ?? this.content,
      actsStep: actsStep ?? this.actsStep,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case JournalEntryType.prayer:
        return 'Oración';
      case JournalEntryType.reflection:
        return 'Reflexión';
      case JournalEntryType.gratitude:
        return 'Gratitud';
      case JournalEntryType.testimony:
        return 'Testimonio';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        topicId,
        content,
        actsStep,
        type,
        tags,
        createdAt,
        updatedAt,
      ];
}
