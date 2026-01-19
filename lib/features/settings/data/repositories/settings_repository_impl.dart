import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/user_preferences_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<UserPreferences> getPreferences(String userId) async {
    return await localDataSource.getPreferences(userId);
  }

  @override
  Future<void> savePreferences(
      String userId, UserPreferences preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);
    await localDataSource.savePreferences(userId, model);
  }

  @override
  Future<String> exportData(String userId) async {
    return await localDataSource.exportData(userId);
  }

  @override
  Future<void> importData(String userId, String jsonData) async {
    await localDataSource.importData(jsonData);
  }

  @override
  Future<void> clearAllData(String userId) async {
    await localDataSource.clearAllData(userId);
  }

  @override
  Future<int> getDatabaseSize() async {
    return await localDataSource.getDatabaseSize();
  }
}
