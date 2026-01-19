import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/database_helper.dart';
import 'ui_kit/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton(() => DatabaseHelper());

  //! Theme
  sl.registerFactory(() => ThemeCubit(sl()));

  //! Features - Prayer Topics
  // TODO: Register prayer topics dependencies

  //! Features - Prayer Session
  // TODO: Register prayer session dependencies

  //! Features - Planner
  // TODO: Register planner dependencies

  //! Features - Bible
  // TODO: Register bible dependencies

  //! Features - Journal
  // TODO: Register journal dependencies

  //! Features - Settings
  // TODO: Register settings dependencies

  //! Features - Stats
  // TODO: Register stats dependencies
}
