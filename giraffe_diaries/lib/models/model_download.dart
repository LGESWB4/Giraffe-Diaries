import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

typedef ProgressCallback = void Function(double progress);

/// ✅ Firebase 초기화
Future<void> initFirebase() async {
  print("✅ Firebase 초기화 중!");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🚀 Firebase App Check (Play Integrity 활성화)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,  // Play Integrity 사용
    appleProvider: AppleProvider.appAttest,
  );

  print("✅ Firebase 초기화 완료!");
}

// 📌 모델 실행 파일이 존재하는지 확인하는 함수
Future<bool> checkModelRunFile(String modelname) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String modelPath = "${appDir.path}/$modelname"; // 수정된 부분
  final File modelFile = File(modelPath);

  if(modelFile.existsSync()){
    return true;
  }
  else{
    return false;
  }
}

Future<void> moveFile(String fileName) async {
  if (await checkModelRunFile(fileName)){
    return;
  }

  try {
    // Source file path
    String sourcePath = "/data/local/tmp/$fileName";
    File sourceFile = File(sourcePath);

    // Check if the source file exists
    if (!sourceFile.existsSync()) {
      debugPrint("Source file does not exist: $sourcePath");
      return;
    }
    // Get app's internal storage directory
    Directory appDir = await getApplicationDocumentsDirectory();
    String destinationPath = "${appDir.path}/$fileName";
    File destinationFile = File(destinationPath);

    // Copy the file instead of renaming
    await sourceFile.copy(destinationPath);


    debugPrint("File moved successfully to: $destinationPath");
  } catch (e) {
    debugPrint("Error moving file: $e");
  }
}

Future<void> model_move() async {
  await moveFile("Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf");
}


/// ✅ 모델 파일 경로 반환
Future<String> getModelFile({ProgressCallback? onProgress}) async {
  final Directory appDir = await getApplicationDocumentsDirectory(); // 앱 데이터 저장 경로
  final String modelPath = "${appDir.path}/Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf"; // 모델 파일 경로
  final File modelFile = File(modelPath); // 모델 파일 객체

  if (await modelFile.exists()) { // 모델 파일이 존재하는지 확인
    final int fileSize = await modelFile.length();
    const int expectedSize = 1928198752; // 6GB
    if (fileSize >= expectedSize) {
      //print("✅ 모델이 이미 존재합니다: $modelPath (${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB)");
      onProgress?.call(1.0);
    } else {
      //print("⚠️ 모델 파일 크기가 올바르지 않습니다. (${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB) 삭제 후 다시 다운로드합니다.");
      await modelFile.delete();
    }
  }      
  return modelPath;
}


/// ✅ Firebase Storage에서 모델 파일 다운로드
Future<String> downloadModelFile({ProgressCallback? onProgress}) async {
    // firebase 초기화
  await initFirebase();
  // 모델 실행 파일 복사
  //await copyModelRunFileNeeded(onProgress: onProgress); //실행 파일 다운로드
  await model_move();

  final String modelPath = await getModelFile(onProgress: onProgress);
  final File modelFile = File(modelPath);

  // 모델 파일이 이미 존재하는 경우 바로 반환
  if (modelFile.existsSync()) {
    print("✅ 모델 파일이 이미 존재합니다.");
    return modelPath;
  }

  // firebase storage 참조
  final Reference ref = FirebaseStorage.instance.ref("/model/Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf");
  
  try { //firebase storage에서 모델 파일 다운로드
    print("🚀 모델 다운로드 시작...");
    final DownloadTask task = ref.writeToFile(modelFile);
    
    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      var totalSize = snapshot.totalBytes; // 파일 전체 크기
      final int downloadedSize = snapshot.bytesTransferred; // 현재까지 받은 크기
      if (totalSize > 0) {  // 파일 전체 크기가 0보다 크면 (-1의 경우 제외)
        final progress = downloadedSize / totalSize;
        onProgress?.call(progress);
      } else {
        totalSize = 1928198752; // 6GB 강제 설정
        final progress = downloadedSize / totalSize;
        onProgress?.call(progress);
      }
    });
    // 다운로드 완료 대기
    await task;

    print("✅ 모델 다운로드 완료: $modelPath");
  } catch (e) {
    print("❌ 모델 다운로드 실패: $e");
    throw Exception("🔥 모델 다운로드 중 오류 발생: $e");
  }
  
  return modelPath; // 이 줄이 포함되어야 합니다.
}