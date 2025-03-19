import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/text_styles.dart';
import '../controllers/diary_controller.dart';
import 'package:llama_library/llama_library.dart';
import '../models/model_load.dart';
class DiaryWriteButton extends GetView<DiaryController> {
  
  const DiaryWriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 40.0,
        top: 20.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isButtonEnabled.value
                ? () => controller.saveDiary()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isButtonEnabled.value
                  ? const Color(0xFFF6AD62)
                  : const Color(0xFFE5E5E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: Text(
              '다 적었어요',
              style: AppTextStyles.buttonText.copyWith(
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}