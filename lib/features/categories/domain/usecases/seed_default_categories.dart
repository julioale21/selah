import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class SeedDefaultCategories implements UseCase<void, NoParams> {
  final CategoryRepository repository;

  SeedDefaultCategories(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.seedDefaultCategories();
  }
}
