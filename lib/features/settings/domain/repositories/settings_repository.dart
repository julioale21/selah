import '../entities/user_preferences.dart';

abstract class SettingsRepository {
  Future<UserPreferences> getPreferences(String userId);
  Future<void> savePreferences(String userId, UserPreferences preferences);
  Future<String> exportData(String userId);
  Future<void> importData(String userId, String jsonData);
  Future<void> clearAllData(String userId);
  Future<int> getDatabaseSize();
}
