import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialised = false;

  // 1. Initialize the Recorder
  Future<void> init() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
    await _recorder.openRecorder();
    _isRecorderInitialised = true;
  }

  // 2. Start Recording
  Future<String> startRecording(String fileName) async {
    if (!_isRecorderInitialised) await init();

    final Directory tempDir = await getTemporaryDirectory();
    final String path = '${tempDir.path}/$fileName.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
    return path;
  }

  // 3. Stop Recording
  Future<String?> stopRecording() async {
    if (!_isRecorderInitialised) return null;
    return await _recorder.stopRecorder();
  }

  // 4. Dispose (Clean up)
  Future<void> close() async {
    await _recorder.closeRecorder();
    _isRecorderInitialised = false;
  }
}