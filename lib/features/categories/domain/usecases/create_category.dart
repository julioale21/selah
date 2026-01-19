import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory implements UseCase<Category, CreateCategoryParams> {
  final CategoryRepository repository;
  static const _uuid = Uuid();

  CreateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) {
    final now = DateTime.now();
    final category = Category(
      id: _uuid.v4(),
      userId: params.userId,
      name: params.name,
      iconName: params.iconName,
      colorHex: params.colorHex,
      sortOrder: params.sortOrder,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
    return repository.createCategory(category);
  }
}

class CreateCategoryParams {
  final String userId;
  final String name;
  final String iconName;
  final String colorHex;
  final int sortOrder;

  const CreateCategoryParams({
    required this.userId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    this.sortOrder = 0,
  });
}
