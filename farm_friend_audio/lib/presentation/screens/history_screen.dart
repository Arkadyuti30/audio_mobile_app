import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/dependency_injection.dart' as di;
import '../../data/models/audio_session.dart';
import '../widgets/history_audio_card.dart'; // Import the widget we just created

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the Hive Box from Service Locator
    final box = di.sl<Box<AudioSession>>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Recording History"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      // Use ValueListenableBuilder to update UI automatically when DB changes
      body: ValueListenableBuilder<Box<AudioSession>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          // 1. Get List and Sort by Date (Newest first)
          final sessions = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No recordings yet", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          // 2. Render List
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return HistoryAudioCard(session: session);
            },
          );
        },
      ),
    );
  }
}