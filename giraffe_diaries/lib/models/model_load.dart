import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:llama_library/llama_library.dart';
import 'package:llama_library/scheme/scheme/api/api.dart';
import 'package:llama_library/scheme/scheme/respond/update_llama_library_message.dart';

Future<LlamaLibrary> modelLoad() async {
  debugPrint("모델 로딩 시작...");

  final Directory appDir = await getApplicationDocumentsDirectory();
  debugPrint('앱 로컬 저장소 경로: ${appDir.path}');
  String modelPath = "${appDir.path}/Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf";

  DynamicLibrary.open("libllama.so");
  debugPrint(".so 파일 확인 완료");

  if (await File(modelPath).exists()) {
    debugPrint("✅ 모델 파일이 존재합니다: $modelPath");
  } else {
    debugPrint("❌ 모델 파일이 존재하지 않습니다. 올바른 경로를 지정하세요.");
  }
  
  final LlamaLibrary llamaLibrary = LlamaLibrary(
    sharedLibraryPath: "libllama.so",
    invokeParametersLlamaLibraryDataOptions:
        InvokeParametersLlamaLibraryDataOptions(
      invokeTimeOut: Duration(minutes: 10),
      isThrowOnError: false,
    ),
  );

  await llamaLibrary.ensureInitialized();
  await llamaLibrary.initialized();

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

  if (res["@type"] == "ok") {
    debugPrint("✅ 모델 로드 완료!");
  } else {
    debugPrint("❌ 모델 로드 실패");
    exit(0);
  }

  return llamaLibrary;
}

Future<String> sendMessage(String text, LlamaLibrary llamaLibrary, bool isDone, Function(String) onUpdate) async {
  if (text == "exit") {
    llamaLibrary.dispose();
    exit(0);
  } else {
    String response = '';
    
    // 응답을 받기 위한 콜백 설정
    llamaLibrary.on(
      eventType: llamaLibrary.eventUpdate,
      onUpdate: (data) {
        final update = data.update;
        if (update is UpdateLlamaLibraryMessage) {
          if (update.is_done == false) {
            final newText = update.text ?? '';
            // UTF-8로 디코딩
            final decodedText = utf8.decode(newText.codeUnits);
            response += decodedText;
            onUpdate(decodedText);
          } else if (update.is_done == true) {
            isDone = true;
          }
        }
      },
    );

    // 메시지 전송
    await llamaLibrary.invoke(
      invokeParametersLlamaLibraryData: InvokeParametersLlamaLibraryData(
        parameters: SendLlamaLibraryMessage.create(
          text: text,
          is_stream: true,
        ),
        isVoid: true,
        extra: null,
        invokeParametersLlamaLibraryDataOptions: null,
      ),
    );

    // 응답이 완료될 때까지 대기
    while (!isDone) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    llamaLibrary.dispose();
    return response;
  }
  llamaLibrary.dispose();
  return '';
}
