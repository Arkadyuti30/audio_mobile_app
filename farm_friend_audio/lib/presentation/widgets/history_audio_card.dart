import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../core/dependency_injection.dart' as di;
import '../../core/services/audio_upload_service.dart';
import '../../data/models/audio_session.dart';

class HistoryAudioCard extends StatefulWidget {
  final AudioSession session;

  const HistoryAudioCard({super.key, required this.session});

  @override
  State<HistoryAudioCard> createState() => _HistoryAudioCardState();
}

class _HistoryAudioCardState extends State<HistoryAudioCard> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isPlayerInitialized = false;
  bool _isLoadingAnalysis = false; // State for the analysis button

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    if (mounted) setState(() => _isPlayerInitialized = true);
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
        fromURI: widget.session.filePath,
        whenFinished: () {
          if (mounted) setState(() => _isPlaying = false);
        },
      );
      setState(() => _isPlaying = true);
    }
  }

  // --- ANALYSIS LOGIC ---

  Future<void> _handleShowAnalysis(BuildContext context) async {
    // 1. Check if synced first
    if (!widget.session.isSynced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please sync this audio first to get analysis."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Set Loading State
    setState(() => _isLoadingAnalysis = true);

    // 3. Call API
    final service = di.sl<AudioUploadService>();
    final data = await service.fetchAnalysis(widget.session.id);

    // 4. Reset Loading State
    if (mounted) {
      setState(() => _isLoadingAnalysis = false);
    }

    // 5. Handle Result
    if (!mounted) return;

    if (data != null) {
      // Success: Show the dialog
      _showAnalysisDialog(
        context,
        transcription: data['transcription'] ?? "No transcription available.",
        // MAPPING: Backend returns 'audio_analysis', we pass it here
        aiResponse: data['audio_analysis'] ?? "No AI analysis available yet.",
      );
    } else {
      // Failure: Show error toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not fetch analysis. Check server connection."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Definition of the dialog method
  void _showAnalysisDialog(BuildContext context, {required String transcription, required String aiResponse}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Analysis Result", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("📝 Transcription:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 4),
              Text(transcription, style: const TextStyle(fontSize: 14)),
              const Divider(height: 24),
              const Text("🤖 AI Analysis:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 4),
              Text(aiResponse, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    // Format Date
    final dt = widget.session.timestamp;
    final dateString = "${dt.day}/${dt.month}/${dt.year} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

    // Format Duration
    final durationString = "0:${widget.session.durationInSeconds.toString().padLeft(2, '0')}";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROW 1: Title & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Audio Recording",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateString,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        durationString,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // ROW 2: Actions
            Row(
              children: [
                // Show Analysis Button (Updated)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingAnalysis
                        ? null // Disable button while loading
                        : () => _handleShowAnalysis(context),
                    icon: _isLoadingAnalysis
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(_isLoadingAnalysis ? "Fetching..." : "Show Analysis"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Sync Icon
                Icon(
                  widget.session.isSynced ? Icons.cloud_done : Icons.cloud_off,
                  color: widget.session.isSynced ? Colors.green : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),

                // Play Button
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _isPlaying ? Colors.redAccent : Colors.green,
                  child: IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    onPressed: _togglePlay,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}