import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<Category> categories;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<Category>? categories,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  List<Category> get defaultCategories =>
      categories.where((c) => c.isDefault).toList();

  List<Category> get customCategories =>
      categories.where((c) => c.isCustom).toList();

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool get isLoading => status == CategoriesStatus.loading;
  bool get hasError => status == CategoriesStatus.error;
  bool get isLoaded => status == CategoriesStatus.loaded;
  bool get isBusy => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        status,
        categories,
        errorMessage,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}
