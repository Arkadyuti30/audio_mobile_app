import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PlayableAudioBubble extends StatefulWidget {
  final String filePath;
  final String duration;

  const PlayableAudioBubble({super.key, required this.filePath, required this.duration});

  @override
  State<PlayableAudioBubble> createState() => _PlayableAudioBubbleState();
}

class _PlayableAudioBubbleState extends State<PlayableAudioBubble> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    setState(() => _isPlayerInitialized = true);
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (!_isPlayerInitialized) return;

    if (_isPlaying) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      await _player.startPlayer(
        fromURI: widget.filePath,
        whenFinished: () {
          setState(() => _isPlaying = false);
        },
      );
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(bottom: 8, left: 60), // Adjusted margins
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF8C6),
        borderRadius: BorderRadius.circular(12).copyWith(topRight: Radius.zero),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.teal.shade700,
              size: 36,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Audio Recording", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(widget.duration, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}