import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class DeleteCategory implements UseCase<void, DeleteCategoryParams> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) {
    return repository.deleteCategory(params.categoryId);
  }
}

class DeleteCategoryParams {
  final String categoryId;

  const DeleteCategoryParams({required this.categoryId});
}
