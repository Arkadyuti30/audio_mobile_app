import 'package:flutter/material.dart';
import 'conversation_screen.dart';
import 'history_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/dependency_injection.dart' as di; // Access your Service Locator
import '../../logic/recording_bloc/recording_bloc.dart';
import 'conversation_screen.dart';
import '../../logic/results_bloc/results_bloc.dart';
import 'package:farm_friend_audio/logic/sync_bloc/sync_bloc.dart';
import 'package:farm_friend_audio/logic/sync_bloc/sync_state.dart';
import 'package:farm_friend_audio/logic/sync_bloc/sync_event.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SyncBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Farm Friend',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.green.shade50,
          elevation: 0,
        ),
        // Wrap the Body in BlocListener to handle Toasts
        body: BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            if (state is SyncFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (state is SyncSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(state.count == 0
                          ? "All files are already synced!"
                          : "Successfully synced ${state.count} files"),
                    ],
                  ),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: Column(
            children: [
              // ---------------------------------------------
              // 1. Top Section: Image & Welcome Text
              // ---------------------------------------------
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Image.asset(
                            'assets/images/veggies.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Text
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 20),
                        child: Text(
                          "Welcome to Farmer Friend\nYour AI assistant to help with phenotyping.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------
              // 2. Bottom Section: The Action Buttons
              // ---------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- HISTORY BUTTON (Left) ---
                    _buildActionButton(
                      context,
                      icon: Icons.history,
                      label: "History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryScreen()),
                        );
                      },
                    ),

                    // --- MIC BUTTON (Center - Large) ---
                    _buildLargeMicButton(
                      context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                    create: (_) => di.sl<RecordingBloc>()),
                                BlocProvider(
                                    create: (_) => di.sl<ResultsBloc>()),
                              ],
                              child: const ConversationScreen(
                                  conversationId: "AGRI-1024"),
                            ),
                          ),
                        );
                      },
                    ),

                    // --- SYNC BUTTON (Right) ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {
                            // Trigger Sync Event
                            context.read<SyncBloc>().add(TriggerSyncEvent());
                          },
                          // Use BlocBuilder ONLY for the Icon to show Spinner
                          icon: BlocBuilder<SyncBloc, SyncState>(
                            builder: (context, state) {
                              if (state is SyncInProgress) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.green,
                                  ),
                                );
                              }
                              return const Icon(Icons.cloud_upload_outlined,
                                  size: 28);
                            },
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sync",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the smaller side buttons (History/Sync)
  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              if (state is SyncInProgress) {
                return const SizedBox(
                  width: 24, height: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                );
              }
              return Icon(icon, size: 28);
            },
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Helper widget for the large central Mic button
  Widget _buildLargeMicButton(BuildContext context, {required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: onTap,
            backgroundColor: Colors.green,
            elevation: 8,
            shape: const CircleBorder(), // Ensures it's perfectly round
            child: const Icon(Icons.mic, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Start Chat",
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}