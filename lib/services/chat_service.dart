import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  final String _apiKey = 'AIzaSyD06U64MI-xdnDLzKgH-Mew9rFj9XMpIbg';
  final String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> getResponse(String query, {String? contextData}) async {
    try {
      String prompt = query;
      if (contextData != null && contextData.isNotEmpty) {
        prompt = "Based on this plant analysis data: $contextData\n\nUser query: $query\n\nProvide a helpful response about the plant condition and treatment recommendations.";
      }

      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': prompt
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      };

      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['candidates'][0]['content']['parts'][0]['text'] ??
            'Sorry, I couldn\'t generate a meaningful response.';
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      return 'Sorry, I encountered an error: $e';
    }
  }
}