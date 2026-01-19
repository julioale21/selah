import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String? sessionId;
  final String? topicId;
  final String content;
  final String? actsStep;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    this.sessionId,
    this.topicId,
    required this.content,
    this.actsStep,
    required this.createdAt,
  });

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? topicId,
    String? content,
    String? actsStep,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      topicId: topicId ?? this.topicId,
      content: content ?? this.content,
      actsStep: actsStep ?? this.actsStep,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        topicId,
        content,
        actsStep,
        createdAt,
      ];
}
