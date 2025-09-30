import 'dart:developer';
import 'package:netratv/services/gemini_api_service.dart';

class ChatService {
  final GeminiApiService _api = GeminiApiService();

  Future<String> sendMessage(List<Map<String, String>> history) async {
    try {
      // Build a simple transcript to preserve some context
      final buffer = StringBuffer();
      for (final m in history) {
        final role = (m['role'] == 'assistant') ? 'Assistant' : 'User';
        final text = m['text'] ?? '';
        buffer.writeln('$role: $text\n');
      }

      final output = await _api.generateText(prompt: buffer.toString());
      if (output.trim().isEmpty) {
        return "⚠️ No valid text response from model.";
      }
      return output;
    } catch (e) {
      log("❌ ChatService error: $e");
      return "⚠️ An error occurred: $e";
    }
  }
}
