import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/diary_screen.dart';
import '../models/model_load.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';

class ImageGenerationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString generatedImageUrl = ''.obs;

  Future<void> generateImage(DateTime selectedDate, String contenttext, String selectedStyle) async {
    try {
      isLoading.value = true;

      // 사용자 이름 가져오기
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '김덕륜';

      // 날짜 포맷팅
      final month = selectedDate.month.toString().padLeft(2, '0');
      final date = selectedDate.day.toString().padLeft(2, '0');

      // 컨텐츠에서 키워드 추출 (예시: 쉼표로 구분된 첫 3개 단어)
      final keywords = contenttext.split(' ').take(3).join(', ');

      // API 호출하여 이미지 생성 (임시) TODO: 추후 변수로 대체
      final imagePath = await ApiService.generateImage(
        username: username, // 실제 사용자 이름으로 대체 필요
        inputWord: keywords,
        month: month,
        date: date,
        styleWord: selectedStyle,
        emotionQuery: "뿌듯함", // 실제 감정으로 대체 필요
      );
      print("imagePath: ${imagePath}");

      // 이미지 URL 생성
      generatedImageUrl.value = ApiService.getImageUrl(imagePath);
      print("generatedImageUrl: ${generatedImageUrl.value}");

      // 다이어리 엔트리 업데이트
      final diaryService = Get.find<DiaryService>();
      final existingEntry = diaryService.getDiaryEntry(selectedDate);
      if (existingEntry != null) {
        final updatedEntry = DiaryEntry(
          username: username,
          date: existingEntry.date,
          content: existingEntry.content,
          style: existingEntry.style,
          emotion: existingEntry.emotion,
          imageUrl: generatedImageUrl.value,
          hashtags: existingEntry.hashtags,
        );
        await diaryService.saveDiaryEntry(updatedEntry);
      }

      // 이미지 생성이 완료되면 일기 화면으로 이동
      Get.off(() => DiaryScreen(
        generatedImageUrl: generatedImageUrl.value,
        selectedDate: selectedDate,
        contenttext: contenttext,
      ));

    } catch (e) {
      print("모델 실행 중 오류 발생: $e");
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