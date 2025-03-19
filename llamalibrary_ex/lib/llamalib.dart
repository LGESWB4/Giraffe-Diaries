import 'dart:convert';
import 'dart:io';
import 'package:llama_library/io/models/model_params.dart';
import 'package:llama_library/llama_library.dart';
import 'package:llama_library/scheme/scheme/api/api.dart';
import 'package:llama_library/scheme/scheme/respond/update_llama_library_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'modelload.dart';
import 'package:llama_library/io/models/context_params.dart';
import 'package:llama_library/io/models/sampler_params.dart';
import 'package:llama_library/io/models/model_params.dart';
import 'package:llama_library/llama_library.dart';

final systemPrompt_emotion = jsonEncode({
    "role": "system",
    "content": "assistant는 감정 분석 전문가 **기린AI**입니다. 사용자의 일기를 읽고 가장 적절한 감정 1개와 핵심 단어를 JSON 형식으로만 출력하세요.\n\n"
    "🔹 **감정 선택:**\n"
    "다음 목록에서 **가장 적절한 감정 1개**를 선택하세요.\n"
    "['기쁨', '행복', '만족', '애정 표현', '즐거움', '자신감', '놀람', '슬픔', '우울', '걱정', '불만', '화남', '두려움', '긴장', '실망', '혼란', '아픔']\n\n"
    "🔹 **핵심 단어:**\n"
    "일기의 주제를 반영하는 **최대 4개의 키워드**만을 선정하세요.\n\n"
    "📌 **총 응답 길이는 50단어 이하로 제한하세요.**\n"
    "📌 **반드시 아래 JSON 형식으로만 출력하세요.**\n"
    "```json\n"
    "{\n"
    "    \"Emotion\": \"감정\",\n"
    "    \"Keywords\": [\"단어1\", \"단어2\", \"단어3\", \"단어4\"]\n"
    "}\n"
    "```\n"
});

final systemPrompt_chat = jsonEncode({
    "role": "system",
    "content": "assistant는 감정을 공감하며 대화하는 감성 챗봇 **기린AI**입니다.\n"
    "항상 **존댓말**을 사용하고, 따뜻하고 자연스러운 말투로 대화하세요.\n\n"
    "🔹 **대화 원칙:**\n"
    "1️⃣ **공감 표현:** 사용자의 감정에 맞게 '정말 힘드셨겠어요.', '좋은 하루였네요!'처럼 적절히 반응하세요.\n"
    "2️⃣ **자연스러운 질문:** 사용자가 더 이야기하고 싶게 부드러운 질문을 던지세요.\n"
    "3️⃣ **부담 없는 대화:** 친구처럼 다정한 말투를 유지하세요.\n"
    "4️⃣ **개인정보 보호:** 이름, 위치 등 개인 정보를 요청하지 마세요.\n\n"
    "📌 **응답은 100단어 이하로 작성하세요.**\n\n"
    "🔹 **예시:**\n"
    "사용자: 오늘 너무 피곤해요...\n"
    "→ **기린AI**: 정말 고생 많으셨어요. 하루 종일 바쁘셨나요? 😢\n\n"
    "사용자: 친구랑 빵집 갔어요!\n"
    "→ **기린AI**: 우와! 어떤 빵이 가장 맛있었나요? 🥐\n\n"
    "사용자: 기분이 싱숭생숭해요.\n"
    "→ **기린AI**: 그럴 때 있죠. 😌 혹시 무슨 일이 있었나요?"
});


String model_name = "Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf";
//String model_name = "ktdsbaseLM-v0.13-onbased-llama3.1-Q4_K_M.gguf";

class LlamaChatService {
  final LlamaLibrary llamaLibrary;
  String currentResponse = '';
  final Function(String) onResponseUpdate;

  LlamaChatService({required this.onResponseUpdate})
      : llamaLibrary = LlamaLibrary(
          sharedLibraryPath: "libllama.so",
          invokeParametersLlamaLibraryDataOptions:
              InvokeParametersLlamaLibraryDataOptions(
            invokeTimeOut: Duration(minutes: 10),
            isThrowOnError: false,
          ),
        ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await llamaLibrary.ensureInitialized();
    await llamaLibrary.initialized();
    await _loadModel();

  }

  Future<void> _loadModel() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    debugPrint('앱 로컬 저장소 경로: ${appDir.path}');
    String modelPath = "${appDir.path}/$model_name";

    if (await File(modelPath).exists()) {
      debugPrint("✅ 모델 파일이 존재합니다: $modelPath");
    } else {
      await model_move();
      //debugPrint("❌ 모델 파일이 존재하지 않습니다. 올바른 경로를 지정하세요.");
      debugPrint("✅ 모델 파일이 복사중: $modelPath");
    }

    final res = await llamaLibrary.invoke(
      invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
        parameters: LoadModelFromFileLlamaLibrary.create(
          model_file_path: modelPath,
        ),
        isVoid: false,
        extra: null,
        invokeParametersLlamaLibraryDataOptions: null,
      ),
    );

    final res = await llamaLibrary.invoke(
      invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
        parameters: .create(
          model_file_path: modelPath,
        ),
        isVoid: false,
        extra: null,
        invokeParametersLlamaLibraryDataOptions: null,
      ),
    );

    print("res: $res");
    if (res["@type"] == "ok") {
      print("Success load Model");
    } else {
      print("Failed load Model");
      throw Exception("Failed to load model");
    }
  }

  Future<void> sendMessage(String text, final chatHistory) async {
    final userPrompt = text;

    chatHistory.addMessage(
      role: LlamaLibraryRole.user,
      content: userPrompt
    );

    String chatHistory_text = systemPrompt_emotion;

    currentResponse = '';
    String utf8response = '';
    String jsonresponse = '';

    llamaLibrary.on(
      eventType: llamaLibrary.eventUpdate,
      onUpdate: (data) {
        final update = data.update;
        if (update is UpdateLlamaLibraryMessage) {
          if (update.is_done == false) {
            if (update.text != null) {
              try {
                // 원본 텍스트 출력
                //debugPrint('원본 텍스트: ${update.text}');
                
                // UTF-8 디코딩 시도
                try {
                  final String utf8Decoded = utf8.decode(update.text!.codeUnits);
                  debugPrint('UTF-8 디코딩 결과: $utf8Decoded');
                  utf8response = utf8Decoded;
                } catch (e) {
                  debugPrint('UTF-8 디코딩 실패: $e');
                }

                // JSON 디코딩 시도
                try {
                  final dynamic jsonDecoded = jsonDecode(update.text!);
                  debugPrint('JSON 디코딩 결과: $jsonDecoded');
                  jsonresponse = jsonDecoded;
                } catch (e) {
                  debugPrint('JSON 디코딩 실패: $e');
                }

                // 현재는 원본 텍스트 사용
                currentResponse += utf8response;
                onResponseUpdate(currentResponse);
              } catch (e) {
                debugPrint('텍스트 처리 중 오류 발생: $e');
              }
            }
          } else if (update.is_done == true) {
            debugPrint('모델 응답 완료');
            print("\n\n-- done --");
            print("currentResponse: $currentResponse");
            print("utf8response: $utf8response");
            print("jsonresponse: $jsonresponse");
          }
        }
      },
    );

    await llamaLibrary.invoke(
      invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
        parameters: SendLlamaLibraryMessage.create(
          text: chatHistory_text,
          is_stream: true,
        ),
        isVoid: true,
        extra: null,
        invokeParametersLlamaLibraryDataOptions: null,
      ),
    );
  }

  void dispose() {
    llamaLibrary.dispose();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late LlamaChatService _chatService;
  bool _isLoading = false;
  final LlamaLibraryChatHistory chatHistory = LlamaLibraryChatHistory();
  
  

  @override
  void initState() {
    super.initState();

    chatHistory.clear();

    final systemPrompt = systemPrompt_chat;

    chatHistory.addMessage(
      role: LlamaLibraryRole.system,
      content: jsonDecode(systemPrompt)['content']
    );

    String adjusted_chatHistory = chatHistory.exportFormat(LlamaLibraryChatFormat.alpaca);
    debugPrint("adjusted_chatHistory: $adjusted_chatHistory");

    _chatService = LlamaChatService(
      onResponseUpdate: (response) {
        setState(() {
          if (_messages.isNotEmpty && _messages.last.isAI) {
            _messages.last.content = response;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _sendMessage(chatHistory) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, isAI: false));
      _messages.add(ChatMessage(content: '', isAI: true));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      await _chatService.sendMessage(text, chatHistory);
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 채팅'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isAI
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isAI ? Colors.grey[200] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message.content),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(chatHistory),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(chatHistory),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String content;
  final bool isAI;

  ChatMessage({required this.content, required this.isAI});
}