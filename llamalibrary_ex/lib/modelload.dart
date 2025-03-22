import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'llamalib.dart';

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
  await moveFile(model_name);
}