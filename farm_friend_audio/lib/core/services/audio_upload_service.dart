import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../data/models/audio_session.dart';

class AudioUploadService {
  // Safe fallback if .env fails
  final String _baseUrl = dotenv.env['API_URL'] ?? "http://10.0.2.2:5000";

  Future<bool> uploadAudio(AudioSession session) async {
    final uri = Uri.parse("$_baseUrl/upload_audio");

    try {
      print("📤 Uploading: ${session.id} to $uri");

      final request = http.MultipartRequest('POST', uri);
      
      // 1. Add the Audio File
      // We look for the file at the path stored in Hive
      request.files.add(await http.MultipartFile.fromPath('file', session.filePath));
      
      // 2. Add Fields from your AudioSession (The ones you HAVE)
      request.fields['audio_id'] = session.id;
      
      // Backend expects 'duration' (int), App has 'durationInSeconds'
      request.fields['duration'] = session.durationInSeconds.toString(); 
      
      // Backend expects 'timestamp' (str), App has DateTime
      request.fields['timestamp'] = session.timestamp.toIso8601String();

      // -----------------------------------------------------------------------
      // 3. HARDCODE THE MISSING FIELDS
      // Since you removed them from Hive, we just send static values here 
      // so the Python backend doesn't crash.
      // -----------------------------------------------------------------------
      request.fields['conversation_id'] = "conv_default_01"; 
      request.fields['farmer_id'] = "farmer_default_01"; 

      // 4. Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Upload Success: ${session.id}");
        return true;
      } else {
        print("❌ Upload Failed: ${response.statusCode}");
        print("Response Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchAnalysis(String audioId) async {
    final uri = Uri.parse("$_baseUrl/job/$audioId");

    try {
      print("🔍 Fetching analysis for: $audioId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Safety check: Ensure status is success
        if (data['status'] == 'success') {
          return data;
        } else {
          print("⚠️ API returned status: ${data['status']}");
          return null;
        }
      } else {
        print("❌ Fetch Failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return null;
    }
  }  
}