import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class ScholarshipService {
  final Gemini _gemini = Gemini.instance;

  Future<String> getScholarships({
    required String state,
    required String category,
    required String incomeBracket,
    required String educationLevel,
    required String stream,
  }) async {
    try {
      final prompt =
          """
# Scholarships Eligibility (India)

You are an Indian education advisor. Based on the following student profile, list relevant scholarships and portals the student is likely eligible for. Provide only concise Markdown with working links.

Student Profile:
- State/UT: $state
- Category: $category (e.g., General, OBC, SC, ST, EWS)
- Family Income: $incomeBracket
- Education Level: $educationLevel (e.g., School, Undergraduate, Postgraduate)
- Stream/Discipline: $stream

Instructions:
- Use headings and bullet lists. For each scholarship include: brief eligibility, benefits, application timeline, and official/credible application link (National Scholarship Portal, state portals, official institutes).
- Prioritize Indian government (central/state) and reputable private scholarships.
- Add a short “Documents Checklist” section tailored to the profile.
- Add a small FAQ section (2–3 Q&A) about common mistakes.
- Tone: neutral Indian English; concise and practical.
""";

      final response = await _gemini.prompt(parts: [Part.text(prompt)]);
      return response?.output ??
          "No scholarships found. Try adjusting criteria.";
    } catch (e) {
      log("❌ ScholarshipService error: $e");
      return "❌ Error fetching scholarships: $e";
    }
  }
}
