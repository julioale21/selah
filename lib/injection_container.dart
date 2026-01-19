import 'package:get_it/get_it.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/database_helper.dart';
import 'core/services/user_service.dart';

// Categories feature
import 'features/categories/data/datasources/category_local_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/domain/usecases/create_category.dart';
import 'features/categories/domain/usecases/delete_category.dart';
import 'features/categories/domain/usecases/get_categories.dart';
import 'features/categories/domain/usecases/reorder_categories.dart';
import 'features/categories/domain/usecases/seed_default_categories.dart';
import 'features/categories/domain/usecases/update_category.dart';
import 'features/categories/presentation/cubit/categories_cubit.dart';

// Prayer Topics feature
import 'features/prayer_topics/data/datasources/prayer_topic_local_datasource.dart';
import 'features/prayer_topics/data/repositories/prayer_topic_repository_impl.dart';
import 'features/prayer_topics/domain/repositories/prayer_topic_repository.dart';
import 'features/prayer_topics/domain/usecases/add_topic.dart';
import 'features/prayer_topics/domain/usecases/delete_topic.dart';
import 'features/prayer_topics/domain/usecases/get_topics.dart';
import 'features/prayer_topics/domain/usecases/update_topic.dart';
import 'features/prayer_topics/presentation/cubit/topics_cubit.dart';

// Prayer Session feature
import 'features/prayer_session/presentation/cubit/prayer_session_cubit.dart';
import 'features/prayer_session/presentation/cubit/session_timer_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => UserService(sl()));

  //! Theme
  sl.registerFactory(() => ThemeCubit(sl()));

  //! Features - Categories
  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => ReorderCategories(sl()));
  sl.registerLazySingleton(() => SeedDefaultCategories(sl()));

  // Cubit
  sl.registerFactory(() => CategoriesCubit(
        getCategories: sl(),
        createCategory: sl(),
        updateCategory: sl(),
        deleteCategory: sl(),
        reorderCategories: sl(),
        seedDefaultCategories: sl(),
        userService: sl(),
      ));

  //! Features - Prayer Topics
  // Data sources
  sl.registerLazySingleton<PrayerTopicLocalDataSource>(
    () => PrayerTopicLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PrayerTopicRepository>(
    () => PrayerTopicRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTopics(sl()));
  sl.registerLazySingleton(() => AddTopic(sl()));
  sl.registerLazySingleton(() => UpdateTopic(sl()));
  sl.registerLazySingleton(() => DeleteTopic(sl()));

  // Cubit
  sl.registerFactory(() => TopicsCubit(
        getTopics: sl(),
        addTopic: sl(),
        updateTopic: sl(),
        deleteTopic: sl(),
        userService: sl(),
      ));

  //! Features - Prayer Session
  // Cubits
  sl.registerFactory(() => SessionTimerCubit());
  sl.registerFactory(() => PrayerSessionCubit(userService: sl()));

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
