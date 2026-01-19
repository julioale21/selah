import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/entities/user_preferences.dart';

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    super.themeMode,
    super.notificationsEnabled,
    super.dailyReminderTime,
    super.defaultSessionMinutes,
    super.showVerseOfDay,
    super.hapticFeedback,
  });

  factory UserPreferencesModel.fromEntity(UserPreferences prefs) {
    return UserPreferencesModel(
      themeMode: prefs.themeMode,
      notificationsEnabled: prefs.notificationsEnabled,
      dailyReminderTime: prefs.dailyReminderTime,
      defaultSessionMinutes: prefs.defaultSessionMinutes,
      showVerseOfDay: prefs.showVerseOfDay,
      hapticFeedback: prefs.hapticFeedback,
    );
  }

  factory UserPreferencesModel.fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return UserPreferencesModel.fromMap(map);
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminderTime;
    if (map['daily_reminder_time'] != null) {
      final parts = (map['daily_reminder_time'] as String).split(':');
      if (parts.length == 2) {
        reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return UserPreferencesModel(
      themeMode: ThemeMode.values[map['theme_mode'] as int? ?? 0],
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 0) == 1,
      dailyReminderTime: reminderTime,
      defaultSessionMinutes: map['default_session_minutes'] as int? ?? 15,
      showVerseOfDay: (map['show_verse_of_day'] as int? ?? 1) == 1,
      hapticFeedback: (map['haptic_feedback'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.index,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'daily_reminder_time': dailyReminderTime != null
          ? '${dailyReminderTime!.hour}:${dailyReminderTime!.minute}'
          : null,
      'default_session_minutes': defaultSessionMinutes,
      'show_verse_of_day': showVerseOfDay ? 1 : 0,
      'haptic_feedback': hapticFeedback ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());
}
