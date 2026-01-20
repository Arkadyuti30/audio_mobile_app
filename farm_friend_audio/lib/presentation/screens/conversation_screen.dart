import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/recording_bloc/recording_bloc.dart';
import '../../logic/recording_bloc/recording_state.dart';
import '../../logic/recording_bloc/recording_event.dart';
import '../../logic/results_bloc/results_bloc.dart';
import '../../logic/results_bloc/results_state.dart';
import '../../logic/results_bloc/results_event.dart';
import '../widgets/playable_audio_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  const ConversationScreen({super.key, required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  // 1. Initial Empty List (No "Hello" message)
  final List<Map<String, dynamic>> messages = [];
  bool isThinking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        title: const Text("Farm Friend AI"),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      // LISTEN TO BOTH BLOCS
      body: MultiBlocListener(
        listeners: [
          // Listener 1: Recording Bloc (Handles Mic -> Audio File)
          BlocListener<RecordingBloc, RecordingState>(
            listener: (context, state) {
              if (state is RecordingSuccess) {
                setState(() {
                  // Add User Audio Bubble immediately
                  messages.add({
                    "role": "user",
                    "type": "audio",
                    "path": state.audioPath,
                    "duration": "0:05", // Placeholder
                  });
                });
                
                // TRIGGER RESULTS BLOC
                context.read<ResultsBloc>().add(ProcessAudioEvent(state.audioPath));
              }
            },
          ),
          
          // Listener 2: Results Bloc (Handles Transcription & Analysis)
          BlocListener<ResultsBloc, ResultsState>(
            listener: (context, state) {
              if (state is ResultsProcessing) {
                setState(() => isThinking = true);
              } else if (state is ResultsSuccess) {
                setState(() {
                  isThinking = false;
                  
                  // 1. Add Transcription Bubble (User side)
                  messages.add({
                    "role": "user",
                    "type": "text",
                    "content": "📝 ${state.transcription}",
                    "isTranscription": true, 
                  });

                  // 2. Add AI Response Bubble
                  messages.add({
                    "role": "ai",
                    "type": "text",
                    "content": state.aiResponse,
                  });
                });
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isThinking && index == messages.length) return _buildProcessingBubble();
                  
                  final msg = messages[index];
                  if (msg['type'] == 'audio') {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: PlayableAudioBubble(
                        filePath: msg['path'],
                        duration: msg['duration'],
                      ),
                    );
                  } else {
                    // Text Bubble (Used for both AI reply and User Transcription)
                    return Align(
                      alignment: msg['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                      child: _buildTextBubble(
                        msg['content'], 
                        isUser: msg['role'] == 'user',
                        isTranscription: msg['isTranscription'] ?? false
                      ),
                    );
                  }
                },
              ),
            ),
            _buildRecordingBand(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingBand(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final isRecording = state is RecordingInProgress;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (isRecording) {
                  context.read<RecordingBloc>().add(StopRecordingEvent());
                } else {
                  context.read<RecordingBloc>().add(StartRecordingEvent("AGRI-1024"));
                }
              },
              child: CircleAvatar(
                radius: 35,
                backgroundColor: isRecording ? Colors.red : const Color(0xFF075E54),
                child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextBubble(String text, {required bool isUser, bool isTranscription = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // Add indentation to distinguish messages
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser 
            ? (isTranscription ? Colors.green.shade50 : const Color(0xFFDCF8C6)) // Transcription is lighter green
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isTranscription ? Border.all(color: Colors.green.shade200) : null,
      ),
      child: Text(
        text, 
        style: TextStyle(
          fontSize: 16, 
          fontStyle: isTranscription ? FontStyle.italic : FontStyle.normal,
          color: isTranscription ? Colors.black87 : Colors.black
        )
      ),
    );
  }

  Widget _buildProcessingBubble() => const Padding(
    padding: EdgeInsets.all(8.0),
    child: Text("AI is analyzing...", style: TextStyle(color: Colors.grey)),
  );
}