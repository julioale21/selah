import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../cubit/verses_cubit.dart';
import '../cubit/verses_state.dart';
import '../widgets/verse_card.dart';

class VersesScreen extends StatefulWidget {
  const VersesScreen({super.key});

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final cubit = context.read<VersesCubit>();
    cubit.loadVerses();
    cubit.loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versículos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllVersesTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildAllVersesTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(SelahSpacing.md),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar versículos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<VersesCubit>().clearSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: SelahSpacing.md),
            ),
            onChanged: (value) {
              context.read<VersesCubit>().search(value);
              setState(() {});
            },
          ),
        ),

        // Category chips
        SizedBox(
          height: 50,
          child: BlocBuilder<VersesCubit, VersesState>(
            buildWhen: (prev, curr) =>
                prev.selectedCategory != curr.selectedCategory ||
                prev.categories != curr.categories,
            builder: (context, state) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.md),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: state.selectedCategory == null,
                      onSelected: (_) {
                        context.read<VersesCubit>().filterByCategory(null);
                      },
                    ),
                  ),
                  ...state.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_capitalizeCategory(category)),
                        selected: state.selectedCategory == category,
                        onSelected: (_) {
                          context.read<VersesCubit>().filterByCategory(
                                state.selectedCategory == category ? null : category,
                              );
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),

        // Verses list
        Expanded(
          child: BlocConsumer<VersesCubit, VersesState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
                context.read<VersesCubit>().clearError();
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final verses = state.filteredVerses;

              if (verses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: SelahSpacing.md),
                      Text(
                        'Sin resultados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'No se encontraron versículos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(SelahSpacing.md),
                itemCount: verses.length,
                separatorBuilder: (context, index) => const SizedBox(height: SelahSpacing.sm),
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  return VerseCard(
                    verse: verse,
                    onFavorite: () {
                      context.read<VersesCubit>().toggleFavorite(verse.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return BlocBuilder<VersesCubit, VersesState>(
      buildWhen: (prev, curr) => prev.favorites != curr.favorites,
      builder: (context, state) {
        if (state.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: SelahSpacing.md),
                Text(
                  'Sin favoritos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Agrega versículos a tus favoritos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(SelahSpacing.md),
          itemCount: state.favorites.length,
          separatorBuilder: (context, index) => const SizedBox(height: SelahSpacing.sm),
          itemBuilder: (context, index) {
            final verse = state.favorites[index];
            return VerseCard(
              verse: verse,
              onFavorite: () {
                context.read<VersesCubit>().toggleFavorite(verse.id);
              },
            );
          },
        );
      },
    );
  }

  String _capitalizeCategory(String category) {
    if (category.isEmpty) return category;
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }
}
