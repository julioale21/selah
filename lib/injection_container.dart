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

// Planner feature
import 'features/planner/data/datasources/planner_local_datasource.dart';
import 'features/planner/data/repositories/planner_repository_impl.dart';
import 'features/planner/domain/repositories/planner_repository.dart';
import 'features/planner/presentation/cubit/planner_cubit.dart';

// Bible feature
import 'features/bible/data/datasources/verse_local_datasource.dart';
import 'features/bible/data/repositories/verse_repository_impl.dart';
import 'features/bible/domain/repositories/verse_repository.dart';
import 'features/bible/presentation/cubit/verses_cubit.dart';

// Journal feature
import 'features/journal/data/datasources/journal_local_datasource.dart';
import 'features/journal/data/repositories/journal_repository_impl.dart';
import 'features/journal/domain/repositories/journal_repository.dart';
import 'features/journal/presentation/cubit/journal_cubit.dart';

// Settings feature
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

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
  sl.registerFactory(() => PrayerSessionCubit(
        userService: sl(),
        verseRepository: sl(),
        settingsRepository: sl(),
      ));

  //! Features - Planner
  // Data sources
  sl.registerLazySingleton<PlannerLocalDataSource>(
    () => PlannerLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(localDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => PlannerCubit(
        plannerRepository: sl(),
        getTopics: sl(),
        userService: sl(),
      ));

  //! Features - Bible
  // Data sources
  sl.registerLazySingleton<VerseLocalDataSource>(
    () => VerseLocalDataSourceImpl(
      databaseHelper: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<VerseRepository>(
    () => VerseRepositoryImpl(localDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => VersesCubit(
        repository: sl(),
        userService: sl(),
      ));

  //! Features - Journal
  // Data sources
  sl.registerLazySingleton<JournalLocalDataSource>(
    () => JournalLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(localDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => JournalCubit(
        repository: sl(),
        userService: sl(),
      ));

  //! Features - Settings
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => SettingsCubit(
        repository: sl(),
        userId: sl<UserService>().currentUserId,
      ));

  //! Features - Stats
  // TODO: Register stats dependencies
}
