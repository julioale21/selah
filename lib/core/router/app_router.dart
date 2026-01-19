import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../injection_container.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CategoriesCubit>(),
          child: const CategoriesScreen(),
        ),
      ),
    ],
  );
}
