import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../../domain/entities/answered_prayer.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/prayer_card.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    context.read<JournalCubit>().loadAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload when app comes back to foreground
      context.read<JournalCubit>().loadAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when navigating back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JournalCubit>().loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Entradas'),
            Tab(text: 'Peticiones'),
          ],
        ),
      ),
      body: BlocListener<JournalCubit, JournalState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<JournalCubit>().clearError();
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _JournalEntriesTab(),
            _PrayersTab(),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<JournalCubit>(),
        child: const _FilterSheet(),
      ),
    );
  }

}

class _JournalEntriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final entriesByDate = state.entriesByDate;

        return Column(
          children: [
            // Add entry button
            Padding(
              padding: const EdgeInsets.all(SelahSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddEntrySheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar entrada'),
                ),
              ),
            ),
            Expanded(
              child: entriesByDate.isEmpty
                  ? SelahEmptyState(
                      icon: Icons.book_outlined,
                      title: 'Sin entradas',
                      description: 'Comienza a escribir tus reflexiones y oraciones',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.md),
                      itemCount: entriesByDate.length,
                      itemBuilder: (context, index) {
                        final date = entriesByDate.keys.elementAt(index);
                        final entries = entriesByDate[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: SelahSpacing.sm),
                              child: Text(
                                _formatDate(date),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                            ),
                            ...entries.map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: SelahSpacing.sm),
                                  child: JournalEntryCard(
                                    entry: entry,
                                    onDelete: () => _confirmDelete(context, entry),
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<JournalCubit>(),
        child: const _AddEntrySheet(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoy';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Ayer';
    }
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _confirmDelete(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar entrada?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalCubit>().deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PrayersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Add prayer button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SelahSpacing.md,
                  SelahSpacing.md,
                  SelahSpacing.md,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddPrayerSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar petición'),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(SelahSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Pendientes (${state.pendingCount})'),
                    Tab(text: 'Respondidas (${state.answeredCount})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _PrayersList(
                      prayers: state.pendingPrayers,
                      isPending: true,
                    ),
                    _PrayersList(
                      prayers: state.answeredPrayers,
                      isPending: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPrayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<JournalCubit>(),
        child: const _AddPrayerSheet(),
      ),
    );
  }
}

class _PrayersList extends StatelessWidget {
  final List<AnsweredPrayer> prayers;
  final bool isPending;

  const _PrayersList({
    required this.prayers,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return SelahEmptyState(
        icon: isPending ? Icons.pending_outlined : Icons.check_circle_outline,
        title: isPending ? 'Sin peticiones pendientes' : 'Sin respuestas aún',
        description: isPending
            ? 'Agrega peticiones para dar seguimiento'
            : 'Tus oraciones respondidas aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.md),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: SelahSpacing.sm),
          child: PrayerCard(
            prayer: prayer,
            isPending: isPending,
            onMarkAnswered:
                isPending ? () => _showMarkAnsweredDialog(context, prayer) : null,
            onDelete: () => _confirmDelete(context, prayer),
          ),
        );
      },
    );
  }

  void _showMarkAnsweredDialog(BuildContext context, AnsweredPrayer prayer) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: SelahColors.success),
            const SizedBox(width: SelahSpacing.xs),
            const Text('¡Oración respondida!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo respondió Dios esta oración?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SelahSpacing.md),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe cómo fue respondida...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<JournalCubit>()
                    .markPrayerAsAnswered(prayer.id, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AnsweredPrayer prayer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar petición?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalCubit>().deletePrayerRequest(prayer.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(SelahSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<JournalCubit>().clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: SelahSpacing.md),
              Text(
                'Tipo de entrada',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: SelahSpacing.sm),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: state.filterType == null,
                    onSelected: (_) {
                      context.read<JournalCubit>().filterByType(null);
                    },
                  ),
                  ...JournalEntryType.values.map((type) {
                    return FilterChip(
                      label: Text(_getTypeLabel(type)),
                      selected: state.filterType == type,
                      onSelected: (selected) {
                        context
                            .read<JournalCubit>()
                            .filterByType(selected ? type : null);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: SelahSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.prayer:
        return 'Oración';
      case JournalEntryType.reflection:
        return 'Reflexión';
      case JournalEntryType.gratitude:
        return 'Gratitud';
      case JournalEntryType.testimony:
        return 'Testimonio';
    }
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet();

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _contentController = TextEditingController();
  JournalEntryType _selectedType = JournalEntryType.reflection;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SelahSpacing.md,
        right: SelahSpacing.md,
        top: SelahSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + SelahSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva entrada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: SelahSpacing.md),
          Wrap(
            spacing: 8,
            children: JournalEntryType.values.map((type) {
              return ChoiceChip(
                label: Text(_getTypeLabel(type)),
                selected: _selectedType == type,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedType = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SelahSpacing.md),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Escribe tu reflexión...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SelahSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.prayer:
        return 'Oración';
      case JournalEntryType.reflection:
        return 'Reflexión';
      case JournalEntryType.gratitude:
        return 'Gratitud';
      case JournalEntryType.testimony:
        return 'Testimonio';
    }
  }

  void _saveEntry() {
    if (_contentController.text.isEmpty) return;

    context.read<JournalCubit>().addEntry(
          content: _contentController.text,
          type: _selectedType,
        );
    Navigator.pop(context);
  }
}

class _AddPrayerSheet extends StatefulWidget {
  const _AddPrayerSheet();

  @override
  State<_AddPrayerSheet> createState() => _AddPrayerSheetState();
}

class _AddPrayerSheetState extends State<_AddPrayerSheet> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SelahSpacing.md,
        right: SelahSpacing.md,
        top: SelahSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + SelahSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva petición de oración',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: SelahSpacing.sm),
          Text(
            'Escribe tu petición y dale seguimiento hasta que Dios responda.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: SelahSpacing.md),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '¿Qué deseas pedirle a Dios?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SelahSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savePrayer,
              icon: const Icon(Icons.add),
              label: const Text('Agregar petición'),
            ),
          ),
        ],
      ),
    );
  }

  void _savePrayer() {
    if (_contentController.text.isEmpty) return;

    context.read<JournalCubit>().addPrayerRequest(
          prayerText: _contentController.text,
        );
    Navigator.pop(context);
  }
}
