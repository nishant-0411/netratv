import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class ChatService {
  final Gemini _gemini = Gemini.instance;

  Future<String> sendMessage(List<Map<String, String>> history) async {
    try {
      final response = await _gemini.chat(
        history.map((msg) {
          return Content(
            role: msg['role']!,
            parts: [Part.text(msg['text']!)],
          );
        }).toList(),
      );

      if (response != null &&
          response.content != null &&
          response.content!.parts != null &&
          response.content!.parts!.isNotEmpty) {
        final lastPart = response.content!.parts!.last;
        if (lastPart is TextPart) {
          return lastPart.text;
        }
      }

      log("⚠️ No valid text part found: ${response?.toString()}");
      return "⚠️ No valid text response from model.";
    } catch (e) {
      log("❌ ChatService error: $e");
      return "⚠️ An error occurred: $e";
    }
  }
}
