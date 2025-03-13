import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/image_loading_screen.dart';
import '../controllers/image_generation_controller.dart';

class StyleSelectController extends GetxController {
  final RxInt selectedStyle = (-1).obs;  // -1은 선택되지 않은 상태
  final DateTime selectedDate;
  final String contenttext;

  StyleSelectController({
    required this.selectedDate,
    required this.contenttext,
  });

  final List<Map<String, String>> styles = [
    {'name': '수채화', 'image': 'assets/images/styles/watercolor.png'},
    {'name': '일러스트', 'image': 'assets/images/styles/illustration.png'},
    {'name': '페인팅', 'image': 'assets/images/styles/painting.png'},
    {'name': '사진', 'image': 'assets/images/styles/photo.png'},
    {'name': '3D', 'image': 'assets/images/styles/3d.png'},
    {'name': '애니메이션', 'image': 'assets/images/styles/animation.png'},
    {'name': '픽셀아트', 'image': 'assets/images/styles/pixel.png'},
    {'name': '잼민그림', 'image': 'assets/images/styles/kids.png'},
  ];

  void selectStyle(int index) {
    selectedStyle.value = index;
  }

  void showExitDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          '그만 쓰고 나갈까요?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),  // 다이얼로그 닫기
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Get.back();  // 다이얼로그 닫기
              Get.back();  // 화면 닫기
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF6AD62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,  // 배경 터치로 닫기 방지
    );
  }

  void skipSelection() {
    Get.back();  // 또는 다음 화면으로 이동하는 로직
  }

  void confirmSelection() {
    if (selectedStyle.value >= 0) {
      // TODO: 선택된 스타일 저장 로직
      Get.put(ImageGenerationController());
      Future.delayed(const Duration(seconds: 10));
      Get.to(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contenttext));  // 또는 다음 화면으로 이동하는 로직
    }
  }
} 