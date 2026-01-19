import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory implements UseCase<Category, UpdateCategoryParams> {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) {
    final category = Category(
      id: params.id,
      userId: params.userId,
      name: params.name,
      iconName: params.iconName,
      colorHex: params.colorHex,
      sortOrder: params.sortOrder,
      isDefault: false,
      createdAt: params.createdAt,
      updatedAt: DateTime.now(),
    );
    return repository.updateCategory(category);
  }
}

class UpdateCategoryParams {
  final String id;
  final String userId;
  final String name;
  final String iconName;
  final String colorHex;
  final int sortOrder;
  final DateTime createdAt;

  const UpdateCategoryParams({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
  });
}
