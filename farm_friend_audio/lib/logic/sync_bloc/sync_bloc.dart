import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/audio_upload_service.dart';
import '../../data/repositories/audio_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final AudioRepository _repository;
  final AudioUploadService _uploadService;

  SyncBloc({
    required AudioRepository repository,
    required AudioUploadService uploadService,
  })  : _repository = repository,
        _uploadService = uploadService,
        super(SyncInitial()) {
    
    on<TriggerSyncEvent>((event, emit) async {
      // 1. Check Internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(SyncFailure("No internet connection"));
        return;
      }

      emit(SyncInProgress());

      try {
        // 2. Get Unsynced Files
        final unsyncedSessions = _repository.getUnsyncedSessions();
        
        if (unsyncedSessions.isEmpty) {
          emit(SyncSuccess(0)); // Nothing to do
          return;
        }

        int successCount = 0;

        // 3. Loop & Upload One by One
        for (var session in unsyncedSessions) {
          final success = await _uploadService.uploadAudio(session);
          
          if (success) {
            await _repository.markAsSynced(session.id);
            successCount++;
          }
        }

        emit(SyncSuccess(successCount));

      } catch (e) {
        emit(SyncFailure("Sync error: $e"));
      }
    });
  }
}