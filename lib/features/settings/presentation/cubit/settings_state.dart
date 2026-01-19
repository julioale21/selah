import 'package:equatable/equatable.dart';

import '../../domain/entities/user_preferences.dart';

enum SettingsStatus {
  initial,
  loading,
  loaded,
  saving,
  exporting,
  importing,
  clearing,
  success,
  error,
}

class SettingsState extends Equatable {
  final SettingsStatus status;
  final UserPreferences preferences;
  final int databaseSizeBytes;
  final String? exportedData;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.preferences = const UserPreferences(),
    this.databaseSizeBytes = 0,
    this.exportedData,
    this.errorMessage,
    this.successMessage,
  });

  String get databaseSizeDisplay {
    if (databaseSizeBytes < 1024) {
      return '$databaseSizeBytes B';
    } else if (databaseSizeBytes < 1024 * 1024) {
      return '${(databaseSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(databaseSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  SettingsState copyWith({
    SettingsStatus? status,
    UserPreferences? preferences,
    int? databaseSizeBytes,
    String? exportedData,
    bool clearExportedData = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      databaseSizeBytes: databaseSizeBytes ?? this.databaseSizeBytes,
      exportedData: clearExportedData ? null : (exportedData ?? this.exportedData),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        preferences,
        databaseSizeBytes,
        exportedData,
        errorMessage,
        successMessage,
      ];
}
