import 'dart:math';

class OfflineLogicService {
  final Random _random = Random();

  // Mock Transcriptions
  final List<String> _mockTranscriptions = [
    "The leaves are turning yellow at the edges and the growth seems stunted.",
    "I have spotted small black bugs on the underside of the maize leaves.",
    "The roots look rotten and there is a bad smell coming from the soil.",
    "There are white powdery spots on the leaves, spreading quickly."
  ];

  // Mock AI Follow-up Questions
  final List<String> _mockFollowUps = [
    "I see. Have you noticed this yellowing spreading to the younger leaves as well?",
    "Could you check if the soil is overly moist or retaining too much water?",
    "Are these spots fuzzy or do they wipe off easily?",
    "How long has this been happening? Just a few days or weeks?"
  ];

  // Simulates "Edge AI" transcription (Speech-to-Text)
  Future<String> transcribeAudio(String audioPath) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing
    return _mockTranscriptions[_random.nextInt(_mockTranscriptions.length)];
  }

  // Simulates "Edge AI" analysis (Text-to-Text)
  Future<String> analyzeAndFollowUp(String transcription) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate thinking
    return _mockFollowUps[_random.nextInt(_mockFollowUps.length)];
  }
}