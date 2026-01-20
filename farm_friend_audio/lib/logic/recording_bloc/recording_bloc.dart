import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/audio_recorder_service.dart';
import '../../data/models/audio_session.dart';
import '../../data/repositories/audio_repository.dart';
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final AudioRecorderService _recorderService;
  final AudioRepository _repository;
  final Uuid _uuid = const Uuid();
  
  DateTime? _startTime; // To calculate duration

  RecordingBloc({
    required AudioRecorderService recorderService,
    required AudioRepository repository,
  })  : _recorderService = recorderService,
        _repository = repository,
        super(RecordingInitial()) {
    
    // --- EVENT: START RECORDING ---
    on<StartRecordingEvent>((event, emit) async {
      try {
        final fileName = _uuid.v4(); // Generate unique ID
        await _recorderService.startRecording(fileName);
        _startTime = DateTime.now();
        emit(RecordingInProgress());
      } catch (e) {
        emit(RecordingFailure("Failed to start recording: $e"));
      }
    });

    // --- EVENT: STOP RECORDING ---
    on<StopRecordingEvent>((event, emit) async {
      try {
        final path = await _recorderService.stopRecording();
        
        if (path != null && _startTime != null) {
          final duration = DateTime.now().difference(_startTime!).inSeconds;
          final audioId = _uuid.v4();

          // 1. Create the Metadata Object
          final session = AudioSession(
            id: audioId,
            filePath: path,
            timestamp: DateTime.now(),
            durationInSeconds: duration,
            isSynced: false,
            transcript: null
          );

          // 2. Save to Hive
          await _repository.saveSession(session);

          emit(RecordingSuccess(path));
        }
      } catch (e) {
        emit(RecordingFailure("Failed to save recording: $e"));
      }
    });
  }
}