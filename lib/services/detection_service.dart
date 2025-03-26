import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisionApiService {
  final String _apiKey = 'AIzaSyACzVLAMqW_XAGZPizLLSyDEbn1wHnj9t0';
  final String _visionApiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 10,
              },
              {
                'type': 'CROP_HINTS',
                'maxResults': 5,
              },
              {
                'type': 'OBJECT_LOCALIZATION',
                'maxResults': 5,
              }
            ],
          },
        ],
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_visionApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }


  Future<String> detectCropCondition(File imageFile) async {
    try {
      final visionResponse = await analyzeImage(imageFile);

      final annotations = visionResponse['responses'][0];
      final labels = annotations['labelAnnotations'] ?? [];

      List<String> labelTexts = [];
      List<String> possibleDiseases = [];

      for (var label in labels) {
        final String description = label['description'].toLowerCase();
        final double score = label['score'] ?? 0.0;

        labelTexts.add(description);

        if (score > 0.7) {
          if (description.contains('disease') ||
              description.contains('blight') ||
              description.contains('mildew') ||
              description.contains('rust') ||
              description.contains('spot') ||
              description.contains('rot')) {
            possibleDiseases.add(description);
          }
        }
      }

      return {
        'labels': labelTexts,
        'possibleDiseases': possibleDiseases
      }.toString();
    } catch (e) {
      return "Error processing image: $e";
    }
  }
}