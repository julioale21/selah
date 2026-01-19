import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/user_service.dart';
import '../../domain/entities/prayer_topic.dart';
import '../../domain/usecases/add_topic.dart';
import '../../domain/usecases/delete_topic.dart';
import '../../domain/usecases/get_topics.dart';
import '../../domain/usecases/update_topic.dart';
import 'topics_state.dart';

class TopicsCubit extends Cubit<TopicsState> {
  final GetTopics getTopics;
  final AddTopic addTopic;
  final UpdateTopic updateTopic;
  final DeleteTopic deleteTopic;
  final UserService userService;

  TopicsCubit({
    required this.getTopics,
    required this.addTopic,
    required this.updateTopic,
    required this.deleteTopic,
    required this.userService,
  }) : super(const TopicsState());

  String get _userId => userService.currentUserId;

  Future<void> loadTopics() async {
    emit(state.copyWith(status: TopicsStatus.loading));

    final result = await getTopics(GetTopicsParams(userId: _userId));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TopicsStatus.error,
        errorMessage: failure.message,
      )),
      (topics) => emit(state.copyWith(
        status: TopicsStatus.loaded,
        topics: topics,
      )),
    );
  }

  Future<void> createTopic({
    required String title,
    String? description,
    String? categoryId,
    required String iconName,
  }) async {
    emit(state.copyWith(isCreating: true));

    final result = await addTopic(AddTopicParams(
      userId: _userId,
      title: title,
      description: description,
      categoryId: categoryId,
      iconName: iconName,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isCreating: false,
        errorMessage: failure.message,
      )),
      (topic) {
        final updatedTopics = [topic, ...state.topics];
        emit(state.copyWith(
          isCreating: false,
          topics: updatedTopics,
        ));
      },
    );
  }

  Future<void> editTopic(PrayerTopic topic) async {
    emit(state.copyWith(isUpdating: true));

    final result = await updateTopic(topic);

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdating: false,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedTopics = state.topics.map((t) {
          return t.id == updated.id ? updated : t;
        }).toList();
        emit(state.copyWith(
          isUpdating: false,
          topics: updatedTopics,
        ));
      },
    );
  }

  Future<void> removeTopic(String id) async {
    emit(state.copyWith(isDeleting: true));

    final result = await deleteTopic(id);

    result.fold(
      (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedTopics = state.topics.where((t) => t.id != id).toList();
        emit(state.copyWith(
          isDeleting: false,
          topics: updatedTopics,
        ));
      },
    );
  }

  void filterByCategory(String? categoryId) {
    if (categoryId == null) {
      emit(state.copyWith(clearCategoryFilter: true));
    } else {
      emit(state.copyWith(selectedCategoryId: categoryId));
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
