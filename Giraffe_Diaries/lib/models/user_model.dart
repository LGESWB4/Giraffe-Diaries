import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

typedef ProgressCallback = void Function(double progress);
// FFI 라이브러리 로드
final DynamicLibrary llamaLib = Platform.isAndroid
    ? DynamicLibrary.open("libllama.so")
    : DynamicLibrary.process();

/// Firebase Storage에서 모델 파일 다운로드
Future<String> downloadModelFile({ProgressCallback? onProgress}) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String modelPath = "${appDir.path}/Llama-3.2-3B-Instruct-BF16.gguf";
  final File modelFile = File(modelPath);

  if (await modelFile.exists()) {
    print("✅ 모델이 이미 존재합니다: $modelPath");
    onProgress?.call(1.0);
    return modelPath;
  }

  print("🚀 모델 다운로드 시작...");
  final Reference ref = FirebaseStorage.instance.ref().child("models/Llama-3.2-3B-Instruct-BF16.gguf");
  
  // 스트리밍 방식으로 다운로드
  final DownloadTask task = ref.writeToFile(modelFile);
  
  // 진행률 모니터링
  task.snapshotEvents.listen((TaskSnapshot snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    onProgress?.call(progress);
  });

  await task.whenComplete(() => print("✅ 모델 다운로드 완료: $modelPath"));
  return modelPath;
}

Future<void> runLlama() async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String modelPath = "${appDir.path}/Llama-3.2-3B-Instruct-BF16.gguf";
  final llama = Llama(modelPath);
  llama.setPrompt("2 * 2 = ?");

  while (true) {
    var (token, done) = llama.getNext();
    print(token);
    if (done) break;
  }
  llama.dispose();
}