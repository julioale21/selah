import '../../../prayer_session/domain/entities/journal_entry.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.userId,
    super.sessionId,
    super.topicId,
    required super.content,
    super.actsStep,
    super.type,
    super.tags,
    required super.createdAt,
    super.updatedAt,
  });

  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      userId: entry.userId,
      sessionId: entry.sessionId,
      topicId: entry.topicId,
      content: entry.content,
      actsStep: entry.actsStep,
      type: entry.type,
      tags: entry.tags,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      sessionId: map['session_id'] as String?,
      topicId: map['topic_id'] as String?,
      content: map['content'] as String,
      actsStep: map['acts_step'] as String?,
      type: JournalEntryType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'prayer'),
        orElse: () => JournalEntryType.prayer,
      ),
      tags: (map['tags'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'topic_id': topicId,
      'content': content,
      'acts_step': actsStep,
      'type': type.name,
      'tags': tags.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
