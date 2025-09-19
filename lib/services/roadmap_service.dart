import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class RoadmapService {
  final Gemini _gemini = Gemini.instance;

  Future<String> getRoadmap(String career) async {
    try {
      final prompt = """
      You are a career mentor. Provide a detailed **step-by-step roadmap** 
      to become a $career. 
      - Use Markdown formatting.
      - Include free resources (websites, courses, YouTube, GitHub).
      - Add milestones (Beginner → Intermediate → Advanced).
      - End with tips for long-term success.
      """;

      final response = await _gemini.prompt(
        parts: [Part.text(prompt)],
      );

      return response?.output ??
          "⚠️ No roadmap generated. Try a different career keyword.";
    } catch (e) {
      log("❌ RoadmapService error: $e");
      return "❌ Error fetching roadmap: $e";
    }
  }
}
