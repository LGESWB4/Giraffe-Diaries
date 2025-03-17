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
  late final ImageGenerationController imageGenerationController;

  StyleSelectController({
    required this.selectedDate,
    required this.contenttext,
  }) {
    if (!Get.isRegistered<ImageGenerationController>()) {
      Get.put(ImageGenerationController());
    }
    imageGenerationController = Get.find<ImageGenerationController>();
  }

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

  // 스타일 선택 후 임시 저장 (로컬)
  void onStyleSelected(String style) async {
    final diaryService = Get.find<DiaryService>();

    final entry = DiaryEntry(
      nickname: nickname,
      date: selectedDate,
      content: contenttext,
      style: style,
      emotion: "",
      imageUrl: "",  // 이미지 URL은 비워둠
      hashtags: [],
    );

    await diaryService.saveDiaryEntry(entry);

    diaryService.printDiaryForDate(selectedDate); // 현재 다이어리 Check
  }

  void skipSelection() {
    onStyleSelected("수채화");
    Get.to(() => ImageLoadingScreen(selectedDate: selectedDate, contenttext: contenttext, selectedStyle: "수채화")); // 또는 다음 화면으로 이동하는 로직
  }

  void confirmSelection() {
    if (selectedStyle.value >= 0) {
      final selectedStyleName = styles[selectedStyle.value]['name']!;

      // 임시로 스타일 정보만 저장
      onStyleSelected(selectedStyleName);

      // 로딩 화면으로 전환하고 이미지 생성 시작
      Get.to(() => ImageLoadingScreen(
        selectedDate: selectedDate,
        contenttext: contenttext,
        selectedStyle: selectedStyleName
      ));
    }
  }
}