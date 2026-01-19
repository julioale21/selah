class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Selah';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'selah.db';
  static const int databaseVersion = 1;

  // Categories
  static const List<String> prayerCategories = [
    'Familia',
    'Iglesia',
    'Trabajo',
    'Salud',
    'Personal',
    'Nación',
  ];

  // ACTS Steps
  static const List<String> actsSteps = [
    'Adoración',
    'Confesión',
    'Gratitud',
    'Súplica',
  ];

  // ACTS Steps English (for internal use)
  static const List<String> actsStepsEn = [
    'Adoration',
    'Confession',
    'Thanksgiving',
    'Supplication',
  ];

  // Default icons por categoría
  static const Map<String, String> categoryIcons = {
    'Familia': 'family_restroom',
    'Iglesia': 'church',
    'Trabajo': 'work',
    'Salud': 'health_and_safety',
    'Personal': 'person',
    'Nación': 'flag',
  };

  // Timer defaults
  static const int defaultSessionMinutes = 15;
  static const int minSessionMinutes = 5;
  static const int maxSessionMinutes = 60;

  // Streak
  static const int streakResetHours = 48;

  // Bible categories
  static const List<String> verseCategories = [
    'fe',
    'amor',
    'esperanza',
    'paz',
    'fortaleza',
    'sabiduría',
    'gratitud',
    'perdón',
    'oración',
    'promesas',
  ];

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyDefaultSessionDuration = 'default_session_duration';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyReminderTime = 'reminder_time';
}
