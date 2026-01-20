abstract class RecordingState {}
class RecordingInitial extends RecordingState {}
class RecordingInProgress extends RecordingState {}
class RecordingSuccess extends RecordingState {
  final String audioPath;
  RecordingSuccess(this.audioPath);
}
class RecordingFailure extends RecordingState {
  final String error;
  RecordingFailure(this.error);
}