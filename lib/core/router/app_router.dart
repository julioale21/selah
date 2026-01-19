import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/planner/presentation/cubit/planner_cubit.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/prayer_session/presentation/cubit/prayer_session_cubit.dart';
import '../../features/prayer_session/presentation/cubit/session_timer_cubit.dart';
import '../../features/prayer_session/presentation/screens/prayer_session_screen.dart';
import '../../features/prayer_topics/presentation/cubit/topics_cubit.dart';
import '../../features/prayer_topics/presentation/screens/topics_screen.dart';
import '../../injection_container.dart';
import 'selah_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: SelahRoutes.home,
    routes: [
      GoRoute(
        path: SelahRoutes.home,
        name: SelahRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
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
        path: SelahRoutes.session,
        name: SelahRoutes.sessionName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<PrayerSessionCubit>()),
            BlocProvider(create: (_) => sl<SessionTimerCubit>()),
            BlocProvider(create: (_) => sl<TopicsCubit>()),
          ],
          child: const PrayerSessionScreen(),
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
    ],
  );
}
