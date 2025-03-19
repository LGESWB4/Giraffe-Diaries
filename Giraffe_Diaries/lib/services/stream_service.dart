import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StreamingService {
  final StreamController<String> _controller = StreamController<String>();

  Stream<String> streamPostRequest(
      String url, Map<String, dynamic> body) async* {
    try {
      // POST 요청 설정
      print("body: $body");
      print("url: $url");
      final request = http.Request('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'application/json';
      // 요청 본문 설정
      request.body = jsonEncode(body);

      // 스트리밍 응답 처리
      final response = await request.send();
      final stream = response.stream.transform(utf8.decoder);
      print("stream start");
      await for (final chunk in stream) {
        // 각 청크를 줄 단위로 처리
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              continue;
            }

            try {
              final jsonData = jsonDecode(data);

              // 에러 체크
              if (jsonData['error'] != null) {
                throw Exception(
                    jsonData['error']['message'] ?? 'Unknown error');
              }

              // 콘텐츠 추출
              final content = jsonData['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              throw Exception('Failed to parse chunk: $e');
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Streaming error: $e');
    } finally {
      await _controller.close();
    }

    yield* _controller.stream;
  }
}
