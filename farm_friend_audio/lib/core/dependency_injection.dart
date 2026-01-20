import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Imports from your project
import '../data/models/audio_session.dart';
import '../data/repositories/audio_repository.dart';
import '../core/services/audio_recorder_service.dart'; // Service
import '../logic/recording_bloc/recording_bloc.dart'; // Audio Recording Bloc
import '../core/services/offline_logic_service.dart'; // Offline Edge logic
import 'package:farm_friend_audio/logic/results_bloc/results_bloc.dart'; // Results Bloc
import '../core/services/audio_upload_service.dart'; // Audio Upload Service
import '../logic/sync_bloc/sync_bloc.dart'; // Sync Bloc

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // 1. External Dependencies & Services
  // ---------------------------------------------------------------------------
  // Register Hive Box
  final audioBox = Hive.box<AudioSession>('audio_sessions');
  sl.registerLazySingleton<Box<AudioSession>>(() => audioBox);

  // Register Audio Service (Hardware)
  sl.registerLazySingleton(() => AudioRecorderService());

  // ---------------------------------------------------------------------------
  // 2. Repositories
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(box: sl()), 
  );

  // ---------------------------------------------------------------------------
  // 3. BLoCs (State Management)
  // ---------------------------------------------------------------------------
  // THIS WAS MISSING: Tell GetIt how to create the RecordingBloc
  sl.registerFactory(() => RecordingBloc(
    recorderService: sl(), // Inject Service
    repository: sl(),      // Inject Repository
  ));

  // Offline Edge logic
  sl.registerLazySingleton(() => OfflineLogicService());
  
  // Result block
  sl.registerFactory(() => ResultsBloc(offlineService: sl()));

  // Audio Upload Service
  sl.registerLazySingleton(() => AudioUploadService());

  // SyncBloc
  sl.registerFactory(() => SyncBloc(repository: sl(), uploadService: sl()));

}