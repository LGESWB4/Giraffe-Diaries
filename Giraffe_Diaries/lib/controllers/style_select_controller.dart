import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/image_loading_screen.dart';
import '../controllers/image_generation_controller.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';

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
    onStyleSelected(styles[selectedStyle.value]['name']!);
    Get.to(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contenttext)); // 또는 다음 화면으로 이동하는 로직
  }

  void confirmSelection() {
    if (selectedStyle.value >= 0) {
      onStyleSelected(styles[selectedStyle.value]['name']!);
      // TODO: 선택된 스타일 저장 로직
      Get.put(ImageGenerationController());
      Future.delayed(const Duration(seconds: 10));
      Get.to(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contenttext));  // 또는 다음 화면으로 이동하는 로직
    }
  }

  void onStyleSelected(String style) async {
    final diaryService = Get.find<DiaryService>();

    final entry = DiaryEntry(
      date: selectedDate,
      content: contenttext,
      style: style,
      emotion: "",
      imageUrl: "",
      hashtags: [],
    );

    await diaryService.saveDiaryEntry(entry);

    // 저장 후 바로 확인
    diaryService.printDiaryForDate(selectedDate);
  }
}