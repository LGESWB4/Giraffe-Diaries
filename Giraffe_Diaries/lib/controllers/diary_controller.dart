import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DiaryController extends GetxController {
  final TextEditingController contentController = TextEditingController();
  final RxBool isButtonEnabled = false.obs;

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
    // TODO: 일기 저장 로직 구현
    Get.back();
  }
}