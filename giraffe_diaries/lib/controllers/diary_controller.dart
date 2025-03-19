import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/style_select_screen.dart';

class DiaryController extends GetxController {
  final TextEditingController contentController = TextEditingController();
  final RxBool isButtonEnabled = false.obs;
  final DateTime selectedDate;

  DiaryController({required this.selectedDate});

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
      Get.to(() => StyleSelectScreen(selectedDate: selectedDate, contenttext: contentController.text));
    }
  }
}