import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

/// Service to manage local user identity
/// This will be replaced with actual auth when migrating to Firebase/Supabase
class UserService {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  UserService(this._prefs);

  /// Get current user ID, creating one if it doesn't exist
  String get currentUserId {
    var userId = _prefs.getString(AppConstants.keyUserId);
    if (userId == null) {
      userId = _uuid.v4();
      _prefs.setString(AppConstants.keyUserId, userId);
    }
    return userId;
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.keyOnboardingComplete, true);
  }

  /// Clear all user data (for logout/reset in future)
  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyOnboardingComplete);
  }

  /// Check if this is a new user (no userId stored yet)
  bool get isNewUser {
    return _prefs.getString(AppConstants.keyUserId) == null;
  }
}
