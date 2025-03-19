import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giraffe_diaries/controllers/image_loading_controller.dart';
import '../screens/image_loading_screen.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';

class StyleSelectController extends GetxController {
  final RxInt selectedStyle = (-1).obs; // -1은 선택되지 않은 상태
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

  // 스타일 선택 후 임시 저장 (로컬)
  void onStyleSelected(String style) async {
    final diaryService = Get.find<DiaryService>();

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final existingEntry = diaryService.getDiaryEntry(selectedDate);
    print("기존 다이어리 항목: ${existingEntry != null}");

    final entry = DiaryEntry(
      username: username,
      date: selectedDate,
      content: contenttext,
      style: style,
      keywords: existingEntry?.keywords ?? "",
      emotion: existingEntry?.emotion ?? "",
      imageUrl: existingEntry?.imageUrl ?? "", // 이미지 URL은 비워둠
      hashtags: existingEntry?.hashtags ?? [''],
    );

    await diaryService.saveDiaryEntry(entry);

    diaryService.printDiaryForDate(selectedDate); // 현재 다이어리 Check
  }

  void skipSelection() {
    onStyleSelected("수채화");
    Get.to(
      () => ImageLoadingScreen(
        selectedDate: selectedDate,
        contenttext: contenttext,
      ),
    ); // 또는 다음 화면으로 이동하는 로직
  }

  void confirmSelection() {
    if (selectedStyle.value >= 0) {
      final selectedStyleName = styles[selectedStyle.value]['name']!;

      // 임시로 스타일 정보만 저장
      onStyleSelected(selectedStyleName);

      // 로딩 화면으로 전환하고 이미지 생성 시작
      Get.to(
        () => ImageLoadingScreen(
          selectedDate: selectedDate,
          contenttext: contenttext,
        ),
      );
    }
  }
}
