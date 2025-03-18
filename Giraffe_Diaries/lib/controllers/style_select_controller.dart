import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/image_loading_screen.dart';
import '../controllers/image_loading_controller.dart';
import '../widgets/exit_confirmation_dialog.dart';

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

  void skipSelection() { // TODO : 그림 일기로 이동
    Get.back();  // 또는 다음 화면으로 이동하는 로직
  }

  void confirmSelection() {
    if (selectedStyle.value >= 0) {
      // TODO: 선택된 스타일 저장 로직
      Get.put(ImageGenerationController());
      Future.delayed(const Duration(seconds: 10));
      Get.to(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contenttext, style: styles[selectedStyle.value]['name'] ?? ''));  // 또는 다음 화면으로 이동하는 로직
    }
  }
}