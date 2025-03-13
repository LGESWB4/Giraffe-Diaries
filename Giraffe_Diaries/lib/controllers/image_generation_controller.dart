import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/diary_screen.dart';

class ImageGenerationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString generatedImageUrl = ''.obs;

  Future<void> generateImage(DateTime selectedDate) async {
    try {
      isLoading.value = true;
      // TODO: 실제 AI 모델 API 연동
      // 임시로 3초 후에 더미 이미지를 반환
      await Future.delayed(const Duration(seconds: 10));
      generatedImageUrl.value = 'assets/generate_images/chillguy.png';
      
      // 이미지 생성이 완료되면 일기 작성 화면으로 이동
      Get.off(() => DiaryScreen(
        generatedImageUrl: generatedImageUrl.value,
        selectedDate: selectedDate,
      ));
    } catch (e) {
      Get.snackbar(
        '오류',
        '이미지 생성에 실패했습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 