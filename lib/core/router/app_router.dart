import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // TODO: Add more routes as features are implemented
    ],
  );
}
