import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/image_loading_screen.dart';
import 'package:llama_library/llama_library.dart';
import '../models/model_load.dart';

class DiaryController extends GetxController {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  final RxList<String> hashtags = <String>[].obs;
  final RxList<String> selectedEmojis = <String>[].obs;
  final RxBool isButtonEnabled = false.obs;
  final DateTime selectedDate;
  late LlamaLibrary llamaLibrary;

  DiaryController({required this.selectedDate});

  Future<void> initialize() async {
    // 필요한 초기화 작업 수행
    await Future.delayed(const Duration(milliseconds: 100)); // 초기화 완료를 시뮬레이션
  }

  @override
  void onInit() {
    super.onInit();
    contentController.addListener(_updateButtonState);
  }

  @override
  void onClose() {
    contentController.removeListener(_updateButtonState);
    contentController.dispose();
    super.onClose();
  }

  void _updateButtonState() {
    isButtonEnabled.value = contentController.text.trim().isNotEmpty;
  }

  void saveDiary() {
    if (contentController.text.trim().isNotEmpty) {
      // 스타일 선택 화면으로 이동 (선택 Date, 일기 내용 contenttext)
      //Get.to(() => StyleSelectScreen(selectedDate: selectedDate, contenttext: contentController.text));

      // image loading screen으로 이동
      Get.off(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contentController.text, selectedStyle: "emotion"));
    }
  }
}