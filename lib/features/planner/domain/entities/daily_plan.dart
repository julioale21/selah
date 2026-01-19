import 'package:equatable/equatable.dart';

class DailyPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> topicIds;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? sessionId;
  final String? notes;

  const DailyPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.topicIds,
    this.isCompleted = false,
    this.completedAt,
    this.sessionId,
    this.notes,
  });

  DailyPlan copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<String>? topicIds,
    bool? isCompleted,
    DateTime? completedAt,
    String? sessionId,
    String? notes,
  }) {
    return DailyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      topicIds: topicIds ?? this.topicIds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        topicIds,
        isCompleted,
        completedAt,
        sessionId,
        notes,
      ];
}
