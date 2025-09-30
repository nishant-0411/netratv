import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// TODO: For production, do not hardcode API keys. Use --dart-define or secure storage.
// Keeping parity with current main.dart initialization for now.
const String kGeminiApiKey = "AIzaSyAxRJIk2anbiibXcizN8-ujJDNUfiHI0Ko";
const String kGeminiApiKeyEnv = String.fromEnvironment('GEMINI_API_KEY');

class GeminiApiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1';
  static const String _baseUrlBeta =
      'https://generativelanguage.googleapis.com/v1beta';
  // Safer default based on user's enabled models
  static const String defaultModel = 'models/gemini-flash-latest';

  final http.Client _client;

  GeminiApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => (kGeminiApiKeyEnv.isNotEmpty)
      ? kGeminiApiKeyEnv
      : kGeminiApiKey;

  Future<String> generateText({
    required String prompt,
    String model = defaultModel,
  }) async {
    if (_apiKey.isEmpty || _apiKey.toLowerCase().contains('your') ) {
      return '❌ Gemini API key is missing. Please pass it via --dart-define=GEMINI_API_KEY=YOUR_KEY or set it securely.';
    }

    Uri buildUri(String base, String mdl) => Uri.parse(
          '$base/$mdl:generateContent?key=$_apiKey',
        );

    Uri uri = buildUri(_baseUrl, model);

    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    };

    // Debug logging
    // ignore: avoid_print
    print('[GeminiApiService] POST -> ' + uri.toString());
    http.Response resp;
    try {
      resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      return '⏱️ Request to Gemini timed out. Please check your connection and try again.';
    } on SocketException catch (e) {
      return '🌐 Network error while contacting Gemini: ${e.message}';
    } catch (e) {
      return '❌ Unexpected error calling Gemini: $e';
    }

    // ignore: avoid_print
    print('[GeminiApiService] Status: ' + resp.statusCode.toString());

    if (resp.statusCode == 404) {
      // Try same model on v1beta first
      final retryUri1 = buildUri(_baseUrlBeta, model);
      print('[GeminiApiService] Retry v1beta -> ' + retryUri1.toString());
      try {
        resp = await _client
            .post(
              retryUri1,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 25));
      } on TimeoutException {
        return '⏱️ Retry to Gemini timed out. Please try again.';
      } on SocketException catch (e) {
        return '🌐 Network error during retry: ${e.message}';
      } catch (e) {
        return '❌ Unexpected error during retry: $e';
      }
      print('[GeminiApiService] Retry v1beta status: ' + resp.statusCode.toString());

      if (resp.statusCode == 404) {
        // User-supported models to attempt in order
        final candidates = <String>{
          model,
          'models/gemini-2.5-flash',
          'models/gemini-2.5-pro',
          'models/gemini-flash-latest',
          'models/gemini-pro-latest',
        }.toList();

        http.Response? lastResp;
        for (final m in candidates) {
          // Try v1 first
          final u1 = buildUri(_baseUrl, m);
          print('[GeminiApiService] Try model on v1 -> ' + u1.toString());
          try {
            lastResp = await _client
                .post(
                  u1,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 25));
          } catch (_) {}
          if (lastResp != null && lastResp.statusCode == 200) {
            resp = lastResp;
            break;
          }

          // Then try v1beta
          final u2 = buildUri(_baseUrlBeta, m);
          print('[GeminiApiService] Try model on v1beta -> ' + u2.toString());
          try {
            lastResp = await _client
                .post(
                  u2,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 25));
          } catch (_) {}
          if (lastResp != null && lastResp.statusCode == 200) {
            resp = lastResp;
            break;
          }
        }
      }
    }

    if (resp.statusCode != 200) {
      try {
        final err = jsonDecode(resp.body) as Map<String, dynamic>;
        final msg = (err['error'] is Map)
            ? ((err['error']['message'] as String?) ?? resp.body)
            : resp.body;
        final hint = (resp.statusCode == 401 || resp.statusCode == 403)
            ? ' Hint: verify your API key and that the Generative Language API is enabled for your project.'
            : '';
        return '❌ Gemini API error (${resp.statusCode}): $msg$hint';
      } catch (_) {
        final hint = (resp.statusCode == 401 || resp.statusCode == 403)
            ? ' Hint: verify your API key and API enablement.'
            : '';
        return '❌ Gemini API error (${resp.statusCode}).$hint';
      }
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return '⚠️ No candidates returned by model.';
    }

    // Extract text from the first candidate
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return '⚠️ Model returned empty content.';
    }
    final firstPart = parts.first as Map<String, dynamic>;
    final text = firstPart['text'] as String?;
    return (text == null || text.trim().isEmpty)
        ? '⚠️ Empty response from model.'
        : text.trim();
  }
}
