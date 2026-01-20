import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/offline_logic_service.dart';
import 'results_event.dart';
import 'results_state.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final OfflineLogicService _offlineService;

  ResultsBloc({required OfflineLogicService offlineService}) 
      : _offlineService = offlineService, 
        super(ResultsInitial()) {

    on<ProcessAudioEvent>((event, emit) async {
      emit(ResultsProcessing());

      try {
        // 1. Check Connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        final bool isOffline = connectivityResult.contains(ConnectivityResult.none);

        String transcription = "";
        String aiResponse = "";

        if (isOffline) {
          // --- OFFLINE MODE (Use Mock Data) ---
          transcription = await _offlineService.transcribeAudio(event.audioPath);
          aiResponse = await _offlineService.analyzeAndFollowUp(transcription);
        } else {
          // --- ONLINE MODE (Future Implementation) ---
          // For now, we fallback to offline logic or show a placeholder
          transcription = "Online Transcription Pending...";
          aiResponse = "Online AI Analysis Pending...";
        }

        emit(ResultsSuccess(
          transcription: transcription,
          aiResponse: aiResponse,
          isOfflineMode: isOffline,
        ));

      } catch (e) {
        emit(ResultsFailure("Analysis Failed: $e"));
      }
    });
  }
}