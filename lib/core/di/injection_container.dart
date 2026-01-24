import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../../features/meditation/data/datasources/meditation_local_datasource.dart';
import '../../features/meditation/data/repositories/meditation_repository_impl.dart';
import '../../features/meditation/domain/repositories/meditation_repository.dart';
import '../../features/meditation/domain/usecases/start_meditation.dart';
import '../../features/meditation/domain/usecases/cancel_meditation.dart';
import '../../features/meditation/domain/usecases/get_saved_settings.dart';
import '../../features/meditation/domain/usecases/save_settings.dart';
import '../../features/meditation/presentation/bloc/meditation_bloc.dart';
import '../../features/meditation/presentation/bloc/timer_bloc.dart';

final getIt = GetIt.instance;

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());

  // Datasources
  getIt.registerLazySingleton<MeditationLocalDatasource>(
    () => MeditationLocalDatasourceImpl(getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerLazySingleton<MeditationRepository>(
    () => MeditationRepositoryImpl(
      localDatasource: getIt<MeditationLocalDatasource>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => StartMeditation(getIt<MeditationRepository>()));
  getIt.registerLazySingleton(() => CancelMeditation(getIt<MeditationRepository>()));
  getIt.registerLazySingleton(() => GetSavedSettings(getIt<MeditationRepository>()));
  getIt.registerLazySingleton(() => SaveSettings(getIt<MeditationRepository>()));

  // Blocs
  getIt.registerFactory(
    () => MeditationBloc(
      startMeditation: getIt<StartMeditation>(),
      cancelMeditation: getIt<CancelMeditation>(),
      getSavedSettings: getIt<GetSavedSettings>(),
      saveSettings: getIt<SaveSettings>(),
    ),
  );

  getIt.registerFactory(() => TimerBloc());
}
