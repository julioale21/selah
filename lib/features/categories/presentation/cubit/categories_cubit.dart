import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/user_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/reorder_categories.dart';
import '../../domain/usecases/seed_default_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final ReorderCategories reorderCategories;
  final SeedDefaultCategories seedDefaultCategories;
  final UserService userService;

  CategoriesCubit({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.reorderCategories,
    required this.seedDefaultCategories,
    required this.userService,
  }) : super(const CategoriesState());

  String get _userId => userService.currentUserId;

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));

    // Ensure default categories exist
    await seedDefaultCategories(NoParams());

    final result = await getCategories(GetCategoriesParams(userId: _userId));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: failure.message,
      )),
      (categories) => emit(state.copyWith(
        status: CategoriesStatus.loaded,
        categories: categories,
      )),
    );
  }

  Future<void> addCategory({
    required String name,
    required String iconName,
    required String colorHex,
  }) async {
    emit(state.copyWith(isCreating: true));

    final result = await createCategory(CreateCategoryParams(
      userId: _userId,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      sortOrder: state.categories.length,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isCreating: false,
        errorMessage: failure.message,
      )),
      (category) {
        final updatedCategories = [...state.categories, category];
        emit(state.copyWith(
          isCreating: false,
          categories: updatedCategories,
        ));
      },
    );
  }

  Future<void> editCategory({
    required String id,
    required String name,
    required String iconName,
    required String colorHex,
  }) async {
    final existing = state.getCategoryById(id);
    if (existing == null || !existing.canEdit) return;

    emit(state.copyWith(isUpdating: true));

    final result = await updateCategory(UpdateCategoryParams(
      id: id,
      userId: existing.userId!,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      sortOrder: existing.sortOrder,
      createdAt: existing.createdAt,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdating: false,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedCategories = state.categories.map((c) {
          return c.id == id ? updated : c;
        }).toList();
        emit(state.copyWith(
          isUpdating: false,
          categories: updatedCategories,
        ));
      },
    );
  }

  Future<void> removeCategory(String id) async {
    final existing = state.getCategoryById(id);
    if (existing == null || !existing.canDelete) return;

    emit(state.copyWith(isDeleting: true));

    final result = await deleteCategory(DeleteCategoryParams(categoryId: id));

    result.fold(
      (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedCategories =
            state.categories.where((c) => c.id != id).toList();
        emit(state.copyWith(
          isDeleting: false,
          categories: updatedCategories,
        ));
      },
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final categories = [...state.categories];
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);

    // Optimistic update
    emit(state.copyWith(categories: categories));

    final categoryIds = categories.map((c) => c.id).toList();
    final result =
        await reorderCategories(ReorderCategoriesParams(categoryIds: categoryIds));

    result.fold(
      (failure) {
        // Revert on failure
        loadCategories();
      },
      (_) {},
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
