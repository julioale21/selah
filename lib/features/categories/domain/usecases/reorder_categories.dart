import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class ReorderCategories implements UseCase<void, ReorderCategoriesParams> {
  final CategoryRepository repository;

  ReorderCategories(this.repository);

  @override
  Future<Either<Failure, void>> call(ReorderCategoriesParams params) {
    return repository.reorderCategories(params.categoryIds);
  }
}

class ReorderCategoriesParams {
  final List<String> categoryIds;

  const ReorderCategoriesParams({required this.categoryIds});
}
