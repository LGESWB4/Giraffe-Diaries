import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:llama_library/llama_library.dart';
import 'package:llama_library/scheme/scheme/api/api.dart';

//String model_name = "Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf";
String model_name = "ktdsbaseLM-v0.13-onbased-llama3.1-Q4_K_M.gguf";

Future<LlamaLibrary> modelLoad() async {
  debugPrint("모델 로딩 시작...");

  final Directory appDir = await getApplicationDocumentsDirectory();
  debugPrint('앱 로컬 저장소 경로: ${appDir.path}');
  String modelPath = "${appDir.path}/$model_name";

  if (await File(modelPath).exists()) {
    debugPrint("✅ 모델 파일이 존재합니다: $modelPath");
  } else {
    debugPrint("❌ 모델 파일이 존재하지 않습니다. 올바른 경로를 지정하세요.");
  }
  
  final LlamaLibrary llamaLibrary = LlamaLibrary(
    sharedLibraryPath: "libllama.so",
    invokeParametersLlamaLibraryDataOptions:
        InvokeParametersLlamaLibraryDataOptions(
      invokeTimeOut: Duration(days: 1),
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
