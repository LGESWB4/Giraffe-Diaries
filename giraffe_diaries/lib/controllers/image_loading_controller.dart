import 'package:get/get.dart';
import 'package:llama_library/llama_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giraffe_diaries/contants/stream_config.dart';
import 'package:giraffe_diaries/controllers/emoji_controller.dart';
import '../services/api_service.dart';
import '../screens/diary_screen.dart';
import '../models/model_load.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'package:flutter/foundation.dart';

// 감정 생성 컨트롤러입니다
class ImageGenerationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString generatedImageUrl = ''.obs;
  late LlamaLibrary llamaLibrary;

  Future<void> generateImage(DateTime selectedDate, String contenttext) async {
    try {
      isLoading.value = true;
      // llamaLibrary = await modelLoad();
      // String modelResponse = await sendMessage(contenttext, llamaLibrary, false, (modelText){
      //   debugPrint("model_res: $modelText");
      // });

      // // modelResponse가 완료된 후 실행될 코드
      // if (modelResponse.isNotEmpty) {
      //   // 응답 처리
      //   debugPrint("모델 응답 완료: $modelResponse");
      //   // 여기에 다음 작업 추가
      // }

      // 사용자 이름 가져오기
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      print("username: $username");

      // 날짜 포맷팅
      final month = selectedDate.month.toString().padLeft(2, '0');
      final date = selectedDate.day.toString().padLeft(2, '0');
      print("month: $month");
      print("date: $date");

      // print("감정 데이터 분석 시작");
      final returnData = await ApiService.getEmotion(
        username,
        month,
        date,
        contenttext,
      );
      // API 호출하여 이미지 생성
      final mainEmotion = returnData[0];
      final keywords = returnData[1];
      print("mainEmotion: $mainEmotion");
      print("keywords: $keywords");

      // 다이어리 엔트리 업데이트
      final diaryService = Get.find<DiaryService>();
      print("다이어리 서비스 가져옴");

      final existingEntry = diaryService.getDiaryEntry(selectedDate);
      print("기존 다이어리 항목: ${existingEntry != null}");

      final updatedEntry = DiaryEntry(
        username: username,
        date: selectedDate,
        content: contenttext,
        style: existingEntry?.style ?? '',
        emotion: mainEmotion,
        imageUrl: '',
        hashtags: existingEntry?.hashtags ?? [],
        keywords: keywords,
      );
      await diaryService.saveDiaryEntry(updatedEntry);
      print("다이어리 항목 업데이트 완료");

      String emojiImagePath = getEmojiPath(mainEmotion);

      // 이미지 화면으로 이동
      print("DiaryScreen으로 이동");
      Get.off(
        () => DiaryScreen(
          selectedDate: selectedDate,
          contenttext: contenttext,
          emojiImagePath: emojiImagePath,
          selectedStyle: '',
          generatedImageUrl: '',
        ),
      );
      print("화면 전환 완료");
    } catch (e) {
      print("모델 실행 중 오류 발생: $e");
      Get.snackbar(
        '오류',
        '이미지 생성에 실패했습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print("generateImage 함수 종료");
    }
  }
}
