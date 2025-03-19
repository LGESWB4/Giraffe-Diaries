import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://35.206.251.58:8000';

  static Future<String> generateImage({
    required String username,
    required String inputWord,
    required String month,
    required String date,
    required String styleWord,
    required String emotionQuery,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/image/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'input_word': inputWord,
          'month': month,
          'date': date,
          'style_word': styleWord,
          'emotion_query': emotionQuery,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data: $data");
        return data['image_path'];
      } else {
        throw Exception('Failed to generate image');
      }
    } catch (e) {
      throw Exception('Error generating image: $e');
    }
  }

  static String getImageUrl(String imagePath) {
    return '$baseUrl/image/$imagePath';
  }


  static Future<String> chatAPI({
    required String username,
    required String inputWord,
    required String month,
    required String date,
    required String styleWord,
    required String emotionQuery,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'input_word': inputWord,
          'month': month,
          'date': date,
          'style_word': styleWord,
          'emotion_query': emotionQuery,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data: $data");
        return data['image_path'];
      } else {
        throw Exception('Failed to generate image');
      }
    } catch (e) {
      throw Exception('Error generating image: $e');
    }
  }
}