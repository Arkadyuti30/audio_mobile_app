import 'package:hive/hive.dart';

// This file name must match the part '...' name below
part 'audio_session.g.dart'; 

@HiveType(typeId: 0) // Unique ID for this class in Hive
class AudioSession extends HiveObject {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final String filePath; // Local path on phone

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final int durationInSeconds;

  @HiveField(4)
  final bool isSynced; // True if "uploaded" (mocked)

  @HiveField(5)
  final String? transcript; // Null initially

  AudioSession({
    required this.id,
    required this.filePath,
    required this.timestamp,
    required this.durationInSeconds,
    this.isSynced = false,
    this.transcript,
  });

  // Helper to create a modified copy (useful for updating status)
  AudioSession copyWith({
    String? id,
    String? filePath,
    DateTime? timestamp,
    int? durationInSeconds,
    bool? isSynced,
    String? transcript,
  }) {
    return AudioSession(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      timestamp: timestamp ?? this.timestamp,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      isSynced: isSynced ?? this.isSynced,
      transcript: transcript ?? this.transcript,
    );
  }
}