import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserPreferences extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final TimeOfDay? dailyReminderTime;
  final int defaultSessionMinutes;
  final bool showVerseOfDay;
  final bool hapticFeedback;

  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = false,
    this.dailyReminderTime,
    this.defaultSessionMinutes = 15,
    this.showVerseOfDay = true,
    this.hapticFeedback = true,
  });

  UserPreferences copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    TimeOfDay? dailyReminderTime,
    bool clearReminderTime = false,
    int? defaultSessionMinutes,
    bool? showVerseOfDay,
    bool? hapticFeedback,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: clearReminderTime ? null : (dailyReminderTime ?? this.dailyReminderTime),
      defaultSessionMinutes: defaultSessionMinutes ?? this.defaultSessionMinutes,
      showVerseOfDay: showVerseOfDay ?? this.showVerseOfDay,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  String get themeModeLabel {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Automático';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }

  String get reminderTimeLabel {
    if (dailyReminderTime == null) return 'No configurada';
    final hour = dailyReminderTime!.hour.toString().padLeft(2, '0');
    final minute = dailyReminderTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [
        themeMode,
        notificationsEnabled,
        dailyReminderTime,
        defaultSessionMinutes,
        showVerseOfDay,
        hapticFeedback,
      ];
}
