import 'dart:convert';
import 'package:llama_library/llama_library.dart';
import 'package:llama_library/scheme/scheme/api/api.dart';
import 'package:llama_library/scheme/scheme/respond/update_llama_library_message.dart';
import 'package:llama_library/scheme/scheme/api/send_llama_library_message.dart';
import 'package:flutter/foundation.dart';

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

final systemPrompt_chat2 = jsonEncode({
    "role": "system",
    "content": "The assistant is an empathetic chatbot called **GirinAI**, designed to engage in emotional conversations.\n"
    "Always use **polite language** and maintain a warm and natural tone in conversations.\n\n"
    
    "🔹 **Conversation Principles:**\n"
    "1️⃣ **Express Empathy:** Respond appropriately to the user's emotions, such as 'That must have been really tough for you.' or 'Sounds like you had a great day!'\n"
    "2️⃣ **Encourage Natural Conversations:** Ask gentle and engaging questions to help users open up.\n"
    "3️⃣ **Maintain a Friendly Tone:** Speak warmly, like a caring friend.\n"
    "4️⃣ **Protect Privacy:** Do not ask for personal information such as names or locations.\n\n"
    
    "📌 **Keep responses within 100 words.**\n\n"
    
    "🔹 **Examples:**\n"
    "User: I'm so tired today...\n"
    "→ **GirinAI**: You must have had a long day. Were you busy all day? 😢\n\n"
    "User: I went to a bakery with my friend!\n"
    "→ **GirinAI**: Wow! What was the most delicious bread you had? 🥐\n\n"
    "User: I'm feeling a bit restless.\n"
    "→ **GirinAI**: I understand. 😌 Did something happen today?"
});



Future<String> sendMessage(String user_text, LlamaLibrary llamaLibrary, bool isDone, String prompt_type, 
Function(String) onUpdate) async {
  String response = '';
  String systemPrompt = '';


  systemPrompt = jsonDecode(systemPrompt_emotion)['content'];

  final chatHistory = LlamaLibraryChatHistory();
  // chatHistory.exportFormat(LlamaLibraryChatFormat.alpaca);
  chatHistory.clear();

  chatHistory.addMessage(
    role: LlamaLibraryRole.system,
    content: systemPrompt
  );


  chatHistory.addMessage(
    role: LlamaLibraryRole.user,
    content: user_text
  );

  debugPrint("chatHistory: ${chatHistory.exportFormat(LlamaLibraryChatFormat.alpaca)}");

  
  // 응답을 받기 위한 콜백 설정
  llamaLibrary.on(
    eventType: llamaLibrary.eventUpdate,
    onUpdate: (data) {
      final update = data.update;
      if (update is UpdateLlamaLibraryMessage) {
        if (update.is_done == false) {
          String newText = update.text ?? '';
          response += newText;
          onUpdate(newText);
          // try {
          //   // UTF-8로 디코딩 시도
          //   final String decodedText = utf8.decode(newText.codeUnits);
          //   // // 깨진 문자나 제어 문자 제거
          //   final cleanText = decodedText.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
          //   response += cleanText;
          //   onUpdate(cleanText);
          // } catch (e) {
          //   debugPrint('디코딩 에러: $e');
          // }
        } else if (update.is_done == true) {
          isDone = true;
          onUpdate("DONE");
        }
      }
    },
  );

    // 메시지 전송 (prompt 포함)
    await llamaLibrary.invoke(
      invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
        parameters: SendLlamaLibraryMessage.create(
          text: user_text,
          is_stream: true,
        ),
        isVoid: true,
        extra: null,
        invokeParametersLlamaLibraryDataOptions:null,
      ),
    );

    // 응답이 완료될 때까지 대기
    while (!isDone) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    chatHistory.addMessage(
      role: LlamaLibraryRole.assistant,
      content: response
    );
    return response;
}

Future<String> chatmessage(String user_text, LlamaLibrary llamaLibrary, bool isDone, final chatHistory, 
Function(String) onUpdate) async {

  // final chatHistory = LlamaLibraryChatHistory();
  // chatHistory.clear();
  String response = '';

  chatHistory.addMessage(
    role: LlamaLibraryRole.system,
    content: jsonDecode(systemPrompt_chat2)['content']
  );

  chatHistory.addMessage(
    role: LlamaLibraryRole.user,
    content: "I'm so glad to see you!"
  );
  
  llamaLibrary.on(
        eventType: llamaLibrary.eventUpdate,
        onUpdate: (data) {
          final update = data.update;
          if (update is UpdateLlamaLibraryMessage) {
            if (update.is_done == false) {
              String newText = update.text ?? '';
              debugPrint('encode Text: $newText');
              // try {
              //  // UTF-8로 디코딩 시도
              //  final String decodedText = utf8.decode(newText.codeUnits);
              //  // // 깨진 문자나 제어 문자 제거
              //  final cleanText = decodedText.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
              //  response += cleanText;
              //  onUpdate(cleanText);
              //  debugPrint('Text: $cleanText');
              // } catch (e) {
              //  debugPrint('디코딩 에러: $e');
              // }
            } else if (update.is_done == true) {
              isDone = true;
              onUpdate("DONE");
            }
          }
        },
      );

    print("chatHistory: ${chatHistory.exportFormat(LlamaLibraryChatFormat.alpaca)}");

    await llamaLibrary.invokeRaw(invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
      parameters: SendLlamaLibraryMessage.create(
        text: chatHistory.exportFormat(LlamaLibraryChatFormat.alpaca),
        is_stream: true,
      ),
      isVoid: true,
      extra: null,
      invokeParametersLlamaLibraryDataOptions:null,
    ));

    while (!isDone) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // chatHistory.addMessage(
    //   role: LlamaLibraryRole.system,
    //   content: response
    // );
    return response;
}