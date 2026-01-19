import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories(String userId) async {
    try {
      final categories = await localDataSource.getCategories(userId);
      return Right(categories);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final category = await localDataSource.getCategoryById(id);
      return Right(category);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final created = await localDataSource.createCategory(model);
      return Right(created);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      if (!category.canEdit) {
        return const Left(CacheFailure(
          message: 'No se pueden editar categorías predefinidas',
        ));
      }
      final model = CategoryModel.fromEntity(category);
      final updated = await localDataSource.updateCategory(model);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderCategories(List<String> categoryIds) async {
    try {
      await localDataSource.reorderCategories(categoryIds);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultCategories() async {
    try {
      await localDataSource.seedDefaultCategories();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> hasDefaultCategories() async {
    try {
      final hasDefaults = await localDataSource.hasDefaultCategories();
      return Right(hasDefaults);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
