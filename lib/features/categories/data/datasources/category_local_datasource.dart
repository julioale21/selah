import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> reorderCategories(List<String> categoryIds);
  Future<void> seedDefaultCategories();
  Future<bool> hasDefaultCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper databaseHelper;

  CategoryLocalDataSourceImpl({required this.databaseHelper});

  static const String _tableName = 'categories';

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final results = await databaseHelper.rawQuery(
        '''
        SELECT * FROM $_tableName
        WHERE user_id IS NULL OR user_id = ?
        ORDER BY sort_order ASC, name ASC
        ''',
        [userId],
      );
      return results.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        throw CacheException(message: 'Categoría no encontrada');
      }

      return CategoryModel.fromMap(results.first);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al obtener categoría: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      await databaseHelper.insert(_tableName, category.toMap());
      return category;
    } catch (e) {
      throw CacheException(message: 'Error al crear categoría: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
      );

      await databaseHelper.update(
        _tableName,
        updatedCategory.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      return updatedCategory;
    } catch (e) {
      throw CacheException(message: 'Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // First check if it's a default category
      final category = await getCategoryById(id);
      if (category.isDefault) {
        throw CacheException(message: 'No se pueden eliminar categorías predefinidas');
      }

      await databaseHelper.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al eliminar categoría: $e');
    }
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        for (var i = 0; i < categoryIds.length; i++) {
          await txn.update(
            _tableName,
            {'sort_order': i, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [categoryIds[i]],
          );
        }
      });
    } catch (e) {
      throw CacheException(message: 'Error al reordenar categorías: $e');
    }
  }

  @override
  Future<void> seedDefaultCategories() async {
    try {
      final hasDefaults = await hasDefaultCategories();
      if (hasDefaults) return;

      final now = DateTime.now();
      final defaultCategories = [
        CategoryModel(
          id: 'cat_familia',
          name: 'Familia',
          iconName: 'family_restroom',
          colorHex: '#E91E63',
          sortOrder: 0,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        CategoryModel(
          id: 'cat_iglesia',
          name: 'Iglesia',
          iconName: 'church',
          colorHex: '#9C27B0',
          sortOrder: 1,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        CategoryModel(
          id: 'cat_trabajo',
          name: 'Trabajo',
          iconName: 'work',
          colorHex: '#3F51B5',
          sortOrder: 2,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        CategoryModel(
          id: 'cat_salud',
          name: 'Salud',
          iconName: 'health_and_safety',
          colorHex: '#4CAF50',
          sortOrder: 3,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        CategoryModel(
          id: 'cat_personal',
          name: 'Personal',
          iconName: 'person',
          colorHex: '#FF9800',
          sortOrder: 4,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        CategoryModel(
          id: 'cat_nacion',
          name: 'Nación',
          iconName: 'flag',
          colorHex: '#795548',
          sortOrder: 5,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        for (final category in defaultCategories) {
          await txn.insert(_tableName, category.toMap());
        }
      });
    } catch (e) {
      throw CacheException(message: 'Error al crear categorías predefinidas: $e');
    }
  }

  @override
  Future<bool> hasDefaultCategories() async {
    try {
      final count = await databaseHelper.count(
        _tableName,
        where: 'is_default = ?',
        whereArgs: [1],
      );
      return count > 0;
    } catch (e) {
      throw CacheException(message: 'Error al verificar categorías: $e');
    }
  }
}
