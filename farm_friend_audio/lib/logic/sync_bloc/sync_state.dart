abstract class SyncState {}
class SyncInitial extends SyncState {}
class SyncInProgress extends SyncState {}
class SyncSuccess extends SyncState {
  final int count; // How many files uploaded
  SyncSuccess(this.count);
}
class SyncFailure extends SyncState {
  final String message;
  SyncFailure(this.message);
}