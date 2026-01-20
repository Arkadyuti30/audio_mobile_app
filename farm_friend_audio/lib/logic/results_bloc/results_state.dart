abstract class ResultsState {}
class ResultsInitial extends ResultsState {}
class ResultsProcessing extends ResultsState {} // Showing "Thinking..."
class ResultsSuccess extends ResultsState {
  final String transcription;
  final String aiResponse;
  final bool isOfflineMode;

  ResultsSuccess({
    required this.transcription,
    required this.aiResponse,
    required this.isOfflineMode,
  });
}
class ResultsFailure extends ResultsState {
  final String error;
  ResultsFailure(this.error);
}