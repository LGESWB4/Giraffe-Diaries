import 'dart:io';
import 'dart:convert';  // utf8을 위해 추가
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:llama_cpp_dart/src/llama.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart'; 
import 'dart:ffi';
import 'package:ffi/ffi.dart';  // Utf8 타입을 위해 추가
import 'package:process_run/shell.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_info2/system_info2.dart';

Future<void> testllama() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception('저장소 접근 권한이 필요합니다');
  }

  final Directory appDir = await getApplicationDocumentsDirectory();
  debugPrint('앱 로컬 저장소 경로: ${appDir.path}');
  String model_path = "/data/local/tmp/Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf";

  DynamicLibrary.open("libllama.so");
  print(".so 파일 확인 완료");
  if (await File(model_path).exists()) {
    print("✅ 모델 파일이 존재합니다: $model_path");
  } else {
    print("❌ 모델 파일이 존재하지 않습니다. 올바른 경로를 지정하세요.");
  }
  // 라이브러리 경로 설정
  Llama.libraryPath = "libllama.so";

  final llama = Llama(model_path);

  final result = await llama.getNext();

  stdout.write(result);
}


Future<void> runllama() async {
    
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception('저장소 접근 권한이 필요합니다');
  }

  final Directory appDir = await getApplicationDocumentsDirectory();
  debugPrint('앱 로컬 저장소 경로: ${appDir.path}');
  String modelPath = "${appDir.path}/Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf";

  // 모델 파일 경로와 라이브러리 경로 설정

  final cores = SysInfo.cores;
  int memory = SysInfo.getTotalVirtualMemory() ~/ megaByte;

  Llama.libraryPath = "libllama.so";

  ModelParams modelParams = ModelParams();

  ContextParams contextParams = ContextParams();
  contextParams.nThreads = cores.length ~/ 2;
  contextParams.nThreadsBatch = cores.length ~/ 2;

  Llama llama =
      Llama(modelPath, modelParams, contextParams);

  String system =
    "You are MistralOrca, a large language model trained by Alignment Lab AI. Write out your reasoning step-by-step to be sure you get the right answers!";
    String prompt = "How are you?";
    String input = """<|im_start|>system\n
    $system<|im_end|>\n
    <|im_start|>user\n
    $prompt<|im_end|>\n
    <|im_start|>assistant\n
    """;

  llama.setPrompt(input);
  while (true) {
    var (token, done) = llama.getNext();
    stdout.write(token);
    if (done) break;
  }
  stdout.write("\n");
  llama.dispose();
}

// Helper function for print with optional terminator
void print(String message, {String terminator = '\n'}) {
  stdout.write(message + terminator);
}

const int megaByte = 1024 * 1024;