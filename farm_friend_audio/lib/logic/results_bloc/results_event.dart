abstract class ResultsEvent {}
class ProcessAudioEvent extends ResultsEvent {
  final String audioPath;
  ProcessAudioEvent(this.audioPath);
}