import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;
  final String userId;

  SettingsCubit({
    required this.repository,
    required this.userId,
  }) : super(const SettingsState());

  Future<void> loadPreferences() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final preferences = await repository.getPreferences(userId);
      final dbSize = await repository.getDatabaseSize();

      emit(state.copyWith(
        status: SettingsStatus.loaded,
        preferences: preferences,
        databaseSizeBytes: dbSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Error al cargar preferencias: $e',
      ));
    }
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final newPrefs = state.preferences.copyWith(themeMode: themeMode);
    await _savePreferences(newPrefs);
  }

  Future<void> updateNotifications(bool enabled) async {
    final newPrefs = state.preferences.copyWith(notificationsEnabled: enabled);
    await _savePreferences(newPrefs);
  }

  Future<void> updateReminderTime(TimeOfDay? time) async {
    final newPrefs = time == null
        ? state.preferences.copyWith(clearReminderTime: true)
        : state.preferences.copyWith(dailyReminderTime: time);
    await _savePreferences(newPrefs);
  }

  Future<void> updateDefaultSessionMinutes(int minutes) async {
    final newPrefs = state.preferences.copyWith(defaultSessionMinutes: minutes);
    await _savePreferences(newPrefs);
  }

  Future<void> updateShowVerseOfDay(bool show) async {
    final newPrefs = state.preferences.copyWith(showVerseOfDay: show);
    await _savePreferences(newPrefs);
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    final newPrefs = state.preferences.copyWith(hapticFeedback: enabled);
    await _savePreferences(newPrefs);
  }

  Future<void> _savePreferences(UserPreferences preferences) async {
    emit(state.copyWith(status: SettingsStatus.saving));

    try {
      await repository.savePreferences(userId, preferences);
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        preferences: preferences,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Error al guardar preferencias: $e',
      ));
    }
  }

  Future<String?> exportData() async {
    emit(state.copyWith(status: SettingsStatus.exporting));

    try {
      final data = await repository.exportData(userId);
      emit(state.copyWith(
        status: SettingsStatus.success,
        exportedData: data,
        successMessage: 'Datos exportados correctamente',
      ));
      return data;
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Error al exportar datos: $e',
      ));
      return null;
    }
  }

  Future<void> importData(String jsonData) async {
    emit(state.copyWith(status: SettingsStatus.importing));

    try {
      await repository.importData(userId, jsonData);
      await loadPreferences();
      emit(state.copyWith(
        status: SettingsStatus.success,
        successMessage: 'Datos importados correctamente',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Error al importar datos: $e',
      ));
    }
  }

  Future<void> clearAllData() async {
    emit(state.copyWith(status: SettingsStatus.clearing));

    try {
      await repository.clearAllData(userId);
      emit(state.copyWith(
        status: SettingsStatus.success,
        preferences: const UserPreferences(),
        databaseSizeBytes: 0,
        successMessage: 'Todos los datos han sido eliminados',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Error al eliminar datos: $e',
      ));
    }
  }

  void clearMessages() {
    emit(state.copyWith(
      clearError: true,
      clearSuccess: true,
      clearExportedData: true,
    ));
  }
}
