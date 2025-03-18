import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
Future<File> checkModelRunFile(String modelname) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String modelPath = "${appDir.path}/$modelname"; // 수정된 부분
  final File modelFile = File(modelPath);
  return modelFile;
}

// 📌 모델 실행 파일을 앱 내부 저장소로 복사하는 함수
Future<void> copyRunFile(File modelFile) async {
  print("📥 모델 파일을 assets에서 내부 저장소로 복사 중...");
  ByteData data = await rootBundle.load("assets/model/Llama-3.2-3B-Instruct-BF16.gguf");
  List<int> bytes = data.buffer.asUint8List();
  await modelFile.writeAsBytes(bytes, flush: true);
}


Future<void> taskFunc(DownloadTask task, ProgressCallback? onProgress, final int totalSize) async {

}

Future<void> runTask(String arch, String modelName, ProgressCallback? onProgress, final int totalSize) async {
  final File modelFile = await checkModelRunFile(modelName);

  if (!await modelFile.exists()) {
    try {
      // firebase storage 참조
      final Reference ref = FirebaseStorage.instance.ref("/model/$arch/$modelName");
      final DownloadTask task = ref.writeToFile(modelFile);

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        final int downloadedSize = snapshot.bytesTransferred; // 현재까지 받은 크기
        final progress = downloadedSize / totalSize;
        onProgress?.call(progress);
      });

      await task;

      //await copyRunFile(modelFile);  //assets 에서 복사
      print("✅ 모델 실행 파일 다운 완료");
    } catch (e) {
      print("❌ 모델 실행 파일 다운 실패: $e");
    }
  }
  else{
    print("✅ 모델 실행 파일 이미 존재합니다.");
  }
}

// 📌 모델 파일을 앱 내부 저장소로 복사하는 함수
Future<void> copyModelRunFileNeeded({ProgressCallback? onProgress}) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late String arch;
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    arch = info.supportedAbis.first;
    if (arch == "arm64-v8a") {
      print("Running on aarch64");
      runTask("aarch64","libllama.so", onProgress, 18560912);
      runTask("aarch64","llama-cli", onProgress, 25341520);
      runTask("aarch64","libggml.so", onProgress, 578296);
      runTask("aarch64","libggml-base.so", onProgress, 4706728);
      runTask("aarch64","libggml-cpu.so", onProgress, 1770736);
      runTask("aarch64","libllava_shared.so", onProgress, 3290912);
      runTask("aarch64","libomp.so", onProgress, 1229304);
    } else if (arch == "x86_64") {
      print("Running on x86_64");
      runTask("x86_64","libllama.so", onProgress, 18350176);
      runTask("x86_64","llama-cli", onProgress, 24405536);
      runTask("x86_64","libggml.so", onProgress, 563624);
      runTask("x86_64","libggml-base.so", onProgress, 4290632);
      runTask("x86_64","libggml-cpu.so", onProgress, 1931104);
      runTask("x86_64","libllava_shared.so", onProgress, 3241856);
      runTask("x86_64","libomp.so", onProgress, 1158008);
    }
  } else if (Platform.isIOS) {
    print("Running on iOS");
  } else {
    print("Unknown platform");
  }
}

Future<void> copyfiles() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo info = await deviceInfo.androidInfo;
  String arch = info.supportedAbis.first;
  print("arch: $arch");
  //await moveFile("Llama-3.2-Rabbit-Ko-3B-Instruct.i1-Q4_K_S.gguf");
  await moveFile("libllama.so");
  await moveFile("llama-cli");
  await moveFile("libggml.so");
  await moveFile("libggml-base.so");
  await moveFile("libggml-cpu.so");
  await moveFile("libllava_shared.so");
  await moveFile("libomp.so");
}

Future<void> moveFile(String fileName) async {
  try {
    // Source file path
    String sourcePath = "/data/local/tmp/$fileName";
    File sourceFile = File(sourcePath);

    // Check if the source file exists
    if (!sourceFile.existsSync()) {
      print("Source file does not exist: $sourcePath");
      return;
    }
    // Get app's internal storage directory
    Directory appDir = await getApplicationDocumentsDirectory();
    String destinationPath = "${appDir.path}/$fileName";
    File destinationFile = File(destinationPath);

    // Copy the file instead of renaming
    await sourceFile.copy(destinationPath);


    print("File moved successfully to: $destinationPath");
  } catch (e) {
    print("Error moving file: $e");
  }
}


/// ✅ 모델 파일 경로 반환
Future<String> getModelFile({ProgressCallback? onProgress}) async {
  final Directory appDir = await getApplicationDocumentsDirectory(); // 앱 데이터 저장 경로
  final String modelPath = "${appDir.path}/Llama-3.2-3B-Instruct-BF16.gguf"; // 모델 파일 경로
  final File modelFile = File(modelPath); // 모델 파일 객체

  if (await modelFile.exists()) { // 모델 파일이 존재하는지 확인
    final int fileSize = await modelFile.length();
    const int expectedSize = 6433687840; // 6GB
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
  final String modelPath = await getModelFile(onProgress: onProgress);
  final File modelFile = File(modelPath);

    // firebase 초기화
  await initFirebase();
  // 모델 실행 파일 복사
  //await copyModelRunFileNeeded(onProgress: onProgress); //실행 파일 다운로드
  await copyfiles();
  // 모델 파일이 이미 존재하는 경우 바로 반환
  if (modelFile.existsSync()) {
    print("✅ 모델 파일이 이미 존재합니다.");
    return modelPath;
  }

  // firebase storage 참조
  final Reference ref = FirebaseStorage.instance.ref("/model/Llama-3.2-3B-Instruct-BF16.gguf");
  
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
        totalSize = 6433687840; // 6GB 강제 설정
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