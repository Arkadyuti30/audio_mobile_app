// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioSessionAdapter extends TypeAdapter<AudioSession> {
  @override
  final int typeId = 0;

  @override
  AudioSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioSession(
      id: fields[0] as String,
      filePath: fields[1] as String,
      timestamp: fields[2] as DateTime,
      durationInSeconds: fields[3] as int,
      isSynced: fields[4] as bool,
      transcript: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.durationInSeconds)
      ..writeByte(4)
      ..write(obj.isSynced)
      ..writeByte(5)
      ..write(obj.transcript);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
