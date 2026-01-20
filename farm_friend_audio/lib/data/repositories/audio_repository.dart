import 'package:hive_flutter/hive_flutter.dart';
import '../models/audio_session.dart';

// -----------------------------------------------------------------------------
// 1. The Interface (Contract)
// -----------------------------------------------------------------------------
abstract class AudioRepository {
  /// Save a new recording to local storage
  Future<void> saveSession(AudioSession session);

  /// Get all recordings sorted by newest first
  List<AudioSession> getAllSessions();

  /// Simulate uploading to the server (Returns success/failure)
  Future<bool> mockUploadSession(String sessionId);
  
  /// Delete a recording
  Future<void> deleteSession(String id);

  /// Syncing audio to backend/ cloud (mock)
  List<AudioSession> getUnsyncedSessions();
  Future<void> markAsSynced(String id);
}

// -----------------------------------------------------------------------------
// 2. The Implementation (Logic)
// -----------------------------------------------------------------------------
class AudioRepositoryImpl implements AudioRepository {
  final Box<AudioSession> _box;

  // We inject the Hive Box via constructor (Dependency Injection)
  AudioRepositoryImpl({required Box<AudioSession> box}) : _box = box;

  @override
  Future<void> saveSession(AudioSession session) async {
    await _box.put(session.id, session);
  }

  @override
  List<AudioSession> getAllSessions() {
    final sessions = _box.values.toList();
    // Sort by timestamp (Newest first)
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions;
  }

  @override
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  @override
  Future<bool> mockUploadSession(String sessionId) async {
    // 1. Simulate Network Latency (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Find the session in Hive
    final session = _box.get(sessionId);

    if (session != null) {
      // 3. Create a copy with 'isSynced = true'
      final updatedSession = session.copyWith(isSynced: true);
      
      // 4. Save it back to Hive
      await _box.put(sessionId, updatedSession);
      
      print("✅ Mock Upload Success for ${session.id}");
      return true;
    }
    
    print("❌ Upload Failed: Session not found");
    return false;
  }

  @override
  List<AudioSession> getUnsyncedSessions() {
    // Filter sessions where isSynced is false
    return _box.values.where((session) => !session.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    final session = _box.get(id);
    if (session != null) {
      // Create a copy with isSynced = true
      // NOTE: We manually create the new object since we didn't generate copyWith
      final updatedSession = AudioSession(
        id: session.id,
        filePath: session.filePath,
        timestamp: session.timestamp,
        durationInSeconds: session.durationInSeconds,
        isSynced: true, // <--- CHANGED
        transcript: session.transcript, 
      );
      
      await _box.put(id, updatedSession);
    }
  }
}