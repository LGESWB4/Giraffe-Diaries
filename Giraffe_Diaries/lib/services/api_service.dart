import 'package:giraffe_diaries/contants/stream_config.dart';
import 'package:giraffe_diaries/controllers/emoji_controller.dart';
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

  static Future<List<String>> getEmotion(String username, String month,
      String date, String selectedStyle, String contenttext) async {
    try {
      const url = 'http://35.206.251.58:8080/v1/chat/completions';
      var body = {
        ...make_config_with_stream_type(false),
        'messages': [
          emotion_prompt_config,
          {"role": "user", "content": contenttext},
        ],
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        print("감정 분석 결과 원본: $content");

        try {
          // Markdown 코드 블록 형식에서 JSON 부분만 추출
          // "```json\n{\n \"Emotion\": \"즐거움\",\n\"Keywords\": [\"서울식물원\", \"체조\", \"재밌는\", \"덕륜\"]\n}\n```"
          String jsonStr = content;

          // ```json 접두사와 ``` 접미사 제거
          if (jsonStr.contains("```")) {
            // 첫 번째 ``` 이후의 내용을 가져옴
            jsonStr = jsonStr.split("```")[1];

            // json 접두사가 있으면 제거
            if (jsonStr.startsWith("json\n")) {
              jsonStr = jsonStr.substring(5);
            }

            // 마지막 ``` 이전의 내용만 가져옴
            if (jsonStr.contains("```")) {
              jsonStr = jsonStr.split("```")[0];
            }
          }

          print("정제된 JSON 문자열: $jsonStr");

          // JSON 파싱
          final Map<String, dynamic> emotionData = jsonDecode(jsonStr.trim());

          // emotionData에서 감정 정보 추출 (대소문자 구분 없이)
          String mainEmotion = '미소';
          if (emotionData.containsKey('Emotion')) {
            mainEmotion = emotionData['Emotion'];
          } else if (emotionData.containsKey('emotion')) {
            mainEmotion = emotionData['emotion'];
          }
          print("주요 감정: $mainEmotion");
          print(emotionData['Keywords']);

          // Keywords를 문자열로 변환 (대괄호 제거)
          String keywords = emotionData['Keywords'].toString();
          if (keywords.startsWith('[') && keywords.endsWith(']')) {
            keywords = keywords.substring(1, keywords.length - 1);
          }

          final imagePath = await ApiService.generateImage(
            username: username,
            inputWord: keywords,
            month: month,
            date: date,
            styleWord: selectedStyle,
            emotionQuery: mainEmotion,
          );

          return [imagePath, mainEmotion];
        } catch (e) {
          // JSON 파싱에 실패한 경우, 문자열 기반으로 판단
          print("JSON 파싱 실패, 문자열 기반으로 판단: $e");
          return ['', ''];
        }
      } else {
        print("감정 분석 API 오류: ${response.statusCode} - ${response.body}");
        return ['', ''];
      }
    } catch (e) {
      print("감정 분석 예외 발생: $e");
      return ['', ''];
    }
  }
}
