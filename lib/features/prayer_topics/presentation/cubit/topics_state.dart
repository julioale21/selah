import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_topic.dart';

enum TopicsStatus { initial, loading, loaded, error }

class TopicsState extends Equatable {
  final TopicsStatus status;
  final List<PrayerTopic> topics;
  final String? errorMessage;
  final String? selectedCategoryId;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const TopicsState({
    this.status = TopicsStatus.initial,
    this.topics = const [],
    this.errorMessage,
    this.selectedCategoryId,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  TopicsState copyWith({
    TopicsStatus? status,
    List<PrayerTopic>? topics,
    String? errorMessage,
    String? selectedCategoryId,
    bool clearCategoryFilter = false,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return TopicsState(
      status: status ?? this.status,
      topics: topics ?? this.topics,
      errorMessage: errorMessage,
      selectedCategoryId: clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  List<PrayerTopic> get filteredTopics {
    if (selectedCategoryId == null) return topics;
    return topics.where((t) => t.categoryId == selectedCategoryId).toList();
  }

  PrayerTopic? getTopicById(String id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  bool get isLoading => status == TopicsStatus.loading;
  bool get hasError => status == TopicsStatus.error;
  bool get isLoaded => status == TopicsStatus.loaded;
  bool get isBusy => isCreating || isUpdating || isDeleting;

  int get totalPrayerCount => topics.fold(0, (sum, t) => sum + t.prayerCount);
  int get totalAnsweredCount => topics.fold(0, (sum, t) => sum + t.answeredCount);

  @override
  List<Object?> get props => [
        status,
        topics,
        errorMessage,
        selectedCategoryId,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}
