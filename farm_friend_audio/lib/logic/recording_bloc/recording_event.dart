abstract class RecordingEvent {}
class StartRecordingEvent extends RecordingEvent {
  final String conversationId;
  StartRecordingEvent(this.conversationId);
}
class StopRecordingEvent extends RecordingEvent {}