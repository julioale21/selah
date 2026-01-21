import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/goals/presentation/cubit/goals_cubit.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/home/presentation/screens/home_content.dart';
import '../../features/journal/presentation/cubit/journal_cubit.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/planner/presentation/cubit/planner_cubit.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/prayer_session/presentation/cubit/prayer_session_cubit.dart';
import '../../features/prayer_session/presentation/cubit/session_timer_cubit.dart';
import '../../features/prayer_session/presentation/screens/prayer_session_screen.dart';
import '../../features/prayer_topics/presentation/cubit/topics_cubit.dart';
import '../../features/prayer_topics/presentation/screens/topics_screen.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stats/presentation/cubit/stats_cubit.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../injection_container.dart';
import '../widgets/main_shell.dart';
import 'selah_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: SelahRoutes.home,
    routes: [
      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SelahRoutes.home,
                name: SelahRoutes.homeName,
                builder: (context, state) => const HomeContent(),
              ),
            ],
          ),
          // Prayer/Session branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SelahRoutes.session,
                name: SelahRoutes.sessionName,
                builder: (context, state) {
                  final topicIds = state.extra as List<String>?;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => sl<PrayerSessionCubit>()),
                      BlocProvider(create: (_) => sl<SessionTimerCubit>()),
                      BlocProvider(create: (_) => sl<TopicsCubit>()),
                    ],
                    child: PrayerSessionScreen(topicIds: topicIds),
                  );
                },
              ),
            ],
          ),
          // Journal branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SelahRoutes.journal,
                name: SelahRoutes.journalName,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<JournalCubit>(),
                  child: const JournalScreen(),
                ),
              ),
            ],
          ),
          // Stats branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SelahRoutes.stats,
                name: SelahRoutes.statsName,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<StatsCubit>(),
                  child: const StatsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Routes outside of the shell (no bottom nav)
      GoRoute(
        path: SelahRoutes.categories,
        name: SelahRoutes.categoriesName,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CategoriesCubit>(),
          child: const CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: SelahRoutes.topics,
        name: SelahRoutes.topicsName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<TopicsCubit>()),
            BlocProvider(create: (_) => sl<CategoriesCubit>()),
          ],
          child: const TopicsScreen(),
        ),
      ),
      GoRoute(
        path: SelahRoutes.planner,
        name: SelahRoutes.plannerName,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PlannerCubit>(),
          child: const PlannerScreen(),
        ),
      ),
      GoRoute(
        path: SelahRoutes.settings,
        name: SelahRoutes.settingsName,
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('settings_page'),
          child: BlocProvider(
            create: (_) => sl<SettingsCubit>(),
            child: const SettingsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: SelahRoutes.goals,
        name: SelahRoutes.goalsName,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<GoalsCubit>(),
          child: const GoalsScreen(),
        ),
      ),
    ],
  );
}
