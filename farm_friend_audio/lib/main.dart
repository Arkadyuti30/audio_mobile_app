import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/dependency_injection.dart' as di;
import 'presentation/screens/home_screen.dart';
import 'data/models/audio_session.dart';
import 'logic/sync_bloc/sync_bloc.dart'; // Import SyncBloc
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Flutter Bloc

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Hive Setup
  await Hive.initFlutter();
  Hive.registerAdapter(AudioSessionAdapter()); 
  await Hive.openBox<AudioSession>('audio_sessions');

  // 3. DI Setup
  await di.init(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Friend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => di.sl<SyncBloc>(),
        child: const HomeScreen(),
      ),
    );
  }
}