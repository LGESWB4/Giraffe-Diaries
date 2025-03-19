import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giraffe_diaries/models/diary_entry.dart';
import 'package:giraffe_diaries/screens/image_loading_screen.dart';
import 'package:giraffe_diaries/services/diary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  void saveDiary() async {
    if (contentController.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '김덕륜';

      final diaryService = Get.find<DiaryService>();
      final existingEntry = diaryService.getDiaryEntry(selectedDate);
      print("기존 다이어리 항목: ${existingEntry != null}");

      if (existingEntry != null) {
        final updatedEntry = DiaryEntry(
          username: username,
          content: contentController.text,
          date: existingEntry.date,
          emotion: existingEntry.emotion,
          hashtags: existingEntry.hashtags,
          imageUrl: existingEntry.imageUrl,
          style: existingEntry.style,
          keywords: existingEntry.keywords,
        );
        await diaryService.saveDiaryEntry(updatedEntry);
        print("다이어리 항목(content: ${contentController.text}) 업데이트 완료");
      }

      Get.to(
        () => ImageLoadingScreen(
          selectedDate: selectedDate,
          contenttext: contentController.text,
        ),
      );
    }
  }
}
