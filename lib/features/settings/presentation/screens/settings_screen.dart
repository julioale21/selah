import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/router/selah_routes.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<SettingsCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          context.read<SettingsCubit>().clearMessages();
        }

        // Update ThemeCubit when theme preference changes
        if (state.status == SettingsStatus.loaded || state.status == SettingsStatus.success) {
          final themeCubit = context.read<ThemeCubit>();
          if (themeCubit.state != state.preferences.themeMode) {
            themeCubit.setTheme(state.preferences.themeMode);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configuración'),
          ),
          body: state.status == SettingsStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(SelahSpacing.screenPadding),
                  children: [
                    // Appearance section
                    _buildSectionHeader(context, 'Apariencia'),
                    _ThemeTile(
                      currentMode: state.preferences.themeMode,
                      onChanged: (mode) {
                        context.read<SettingsCubit>().updateThemeMode(mode);
                        context.read<ThemeCubit>().setTheme(mode);
                      },
                    ),
                    const Divider(),

                    // Prayer section
                    _buildSectionHeader(context, 'Oración'),
                    ListTile(
                      leading: const Icon(Icons.flag_rounded),
                      title: const Text('Meta de oración'),
                      subtitle: const Text('Establece tu objetivo diario'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(SelahRoutes.goals),
                    ),
                    _SessionDurationTile(
                      currentMinutes: state.preferences.defaultSessionMinutes,
                      onChanged: (minutes) => context
                          .read<SettingsCubit>()
                          .updateDefaultSessionMinutes(minutes),
                    ),
                    SwitchListTile(
                      title: const Text('Modo enfocado por defecto'),
                      subtitle: const Text(
                          'Iniciar sesiones en pantalla minimalista'),
                      value: state.preferences.defaultFocusMode,
                      onChanged: (value) => context
                          .read<SettingsCubit>()
                          .updateDefaultFocusMode(value),
                    ),
                    SwitchListTile(
                      title: const Text('Versículo del día'),
                      subtitle:
                          const Text('Mostrar versículo al abrir la app'),
                      value: state.preferences.showVerseOfDay,
                      onChanged: (value) => context
                          .read<SettingsCubit>()
                          .updateShowVerseOfDay(value),
                    ),
                    const Divider(),

                    // Notifications section
                    _buildSectionHeader(context, 'Notificaciones'),
                    SwitchListTile(
                      title: const Text('Recordatorios'),
                      subtitle: const Text('Recibir recordatorios de oración'),
                      value: state.preferences.notificationsEnabled,
                      onChanged: (value) => context
                          .read<SettingsCubit>()
                          .updateNotifications(value),
                    ),
                    if (state.preferences.notificationsEnabled)
                      _ReminderTimeTile(
                        currentTime: state.preferences.dailyReminderTime,
                        onChanged: (time) => context
                            .read<SettingsCubit>()
                            .updateReminderTime(time),
                      ),
                    const Divider(),

                    // Accessibility section
                    _buildSectionHeader(context, 'Accesibilidad'),
                    SwitchListTile(
                      title: const Text('Vibración'),
                      subtitle: const Text('Retroalimentación háptica'),
                      value: state.preferences.hapticFeedback,
                      onChanged: (value) => context
                          .read<SettingsCubit>()
                          .updateHapticFeedback(value),
                    ),
                    const Divider(),

                    // Data section
                    _buildSectionHeader(context, 'Datos'),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Tamaño de datos'),
                      trailing: Text(state.databaseSizeDisplay),
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload),
                      title: const Text('Exportar datos'),
                      subtitle: const Text('Guardar una copia de tus datos'),
                      onTap: state.status == SettingsStatus.exporting
                          ? null
                          : () => _exportData(context),
                      trailing: state.status == SettingsStatus.exporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Importar datos'),
                      subtitle: const Text('Restaurar datos desde archivo'),
                      onTap: state.status == SettingsStatus.importing
                          ? null
                          : () => _importData(context),
                      trailing: state.status == SettingsStatus.importing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever,
                          color: Colors.red),
                      title: const Text('Eliminar todos los datos',
                          style: TextStyle(color: Colors.red)),
                      subtitle: const Text('Esta acción no se puede deshacer'),
                      onTap: state.status == SettingsStatus.clearing
                          ? null
                          : () => _confirmClearData(context),
                      trailing: state.status == SettingsStatus.clearing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    const Divider(),

                    // Info section
                    _buildSectionHeader(context, 'Información'),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Versión'),
                      trailing: Text('1.0.0'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Licencias'),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'Selah',
                        applicationVersion: '1.0.0',
                      ),
                    ),
                    const SizedBox(height: SelahSpacing.xl),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final data = await cubit.exportData();

    if (data != null && context.mounted) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now()
            .toIso8601String()
            .replaceAll(':', '-')
            .split('.')[0];
        final file = File('${directory.path}/selah_backup_$timestamp.json');
        await file.writeAsString(data);

        if (context.mounted) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              subject: 'Backup de Selah',
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al exportar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null &&
          result.files.single.path != null &&
          context.mounted) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();

        if (context.mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Importar datos'),
              content: const Text(
                '¿Estás seguro de importar estos datos? '
                'Los datos existentes con el mismo ID serán reemplazados.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Importar'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            context.read<SettingsCubit>().importData(jsonData);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todos los datos'),
        content: const Text(
          '¿Estás seguro de eliminar todos tus datos? '
          'Esta acción no se puede deshacer. '
          'Se eliminarán todas tus categorías, temas de oración, '
          'sesiones, entradas del diario y configuraciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<SettingsCubit>().clearAllData();
    }
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIcon()),
      title: const Text('Tema'),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {currentMode},
        onSelectionChanged: (selected) {
          onChanged(selected.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  IconData _getIcon() {
    switch (currentMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

class _SessionDurationTile extends StatelessWidget {
  final int currentMinutes;
  final ValueChanged<int> onChanged;

  const _SessionDurationTile({
    required this.currentMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Duración de sesión'),
      subtitle: Text('$currentMinutes minutos por defecto'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: currentMinutes > 5
                ? () => onChanged(currentMinutes - 5)
                : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$currentMinutes',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: currentMinutes < 60
                ? () => onChanged(currentMinutes + 5)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ReminderTimeTile extends StatelessWidget {
  final TimeOfDay? currentTime;
  final ValueChanged<TimeOfDay?> onChanged;

  const _ReminderTimeTile({
    required this.currentTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('Hora del recordatorio'),
      trailing: OutlinedButton(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: currentTime ?? const TimeOfDay(hour: 8, minute: 0),
          );
          if (time != null) {
            onChanged(time);
          }
        },
        child: Text(
          currentTime != null
              ? '${currentTime!.hour.toString().padLeft(2, '0')}:${currentTime!.minute.toString().padLeft(2, '0')}'
              : 'Configurar',
        ),
      ),
    );
  }
}
