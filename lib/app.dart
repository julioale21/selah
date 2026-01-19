import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'ui_kit/theme/selah_theme.dart';
import 'ui_kit/theme/theme_cubit.dart';
import 'injection_container.dart';

class SelahApp extends StatelessWidget {
  const SelahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Selah',
            debugShowCheckedModeBanner: false,
            theme: SelahTheme.lightTheme,
            darkTheme: SelahTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
