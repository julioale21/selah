import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  /// Get all categories for a user (includes default categories)
  Future<Either<Failure, List<Category>>> getCategories(String userId);

  /// Get a single category by ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Create a new custom category
  Future<Either<Failure, Category>> createCategory(Category category);

  /// Update an existing custom category
  Future<Either<Failure, Category>> updateCategory(Category category);

  /// Delete a custom category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Reorder categories
  Future<Either<Failure, void>> reorderCategories(List<String> categoryIds);

  /// Seed default categories if they don't exist
  Future<Either<Failure, void>> seedDefaultCategories();

  /// Check if default categories have been seeded
  Future<Either<Failure, bool>> hasDefaultCategories();
}
