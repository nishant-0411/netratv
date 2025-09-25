import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class RoadmapService {
  final Gemini _gemini = Gemini.instance;

  Future<String> getRoadmap(String career) async {
    try {
      final prompt =
          """
# To Become a $career (India-focused)

Provide a practical, step-by-step roadmap for someone in India to become a $career.

Requirements:
- Use clear Markdown with headings, lists and tables where helpful.
- Structure by stages: Beginner → Intermediate → Advanced → Job Prep.
- Include India-specific context: entrance exams (if any), top Indian institutes, recruitment cycles, fresher roles, expected salaries (ranges), and relevant Indian portals.
- Recommend free and paid resources with working links: NPTEL, SWAYAM, GeeksforGeeks, YouTube channels (India-based where possible), Coursera/Udemy, official docs, GitHub projects.
- Provide a weekly study plan sample (4-8 weeks) with measurable outcomes.
- Add a small FAQ (3-5 Q&A) tailored to India.
- Tone: concise, encouraging, and in neutral Indian English.

Deliver only Markdown. Avoid disclaimers.
""";

      final response = await _gemini.prompt(parts: [Part.text(prompt)]);

      return response?.output ??
          "⚠️ No roadmap generated. Try a different career keyword.";
    } catch (e) {
      log("❌ RoadmapService error: $e");
      return "❌ Error fetching roadmap: $e";
    }
  }
}
