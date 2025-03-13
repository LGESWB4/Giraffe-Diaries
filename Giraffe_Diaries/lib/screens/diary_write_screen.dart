import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diary_controller.dart';
import '../styles/text_styles.dart';
import '../widgets/diary_write_button.dart';
import '../widgets/exit_confirmation_dialog.dart';

class DiaryWriteScreen extends GetView<DiaryController> {
  final DateTime selectedDate;

  const DiaryWriteScreen({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(DiaryController());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,  // 키보드가 올라올 때 화면 리사이즈 방지
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.dialog(const ExitConfirmationDialog(), barrierDismissible: false,),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            // 상단 로고와 날짜
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/giraffe_logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedDate.month}월 ${selectedDate.day}일',
                        style: AppTextStyles.heading2,
                      ),
                      Text(
                        ['월', '화', '수', '목', '금', '토', '일'][selectedDate.weekday - 1] + '요일',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 구분선 추가
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFE5E5E5),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
            ),
            const SizedBox(height: 20),
            // 내용 입력 영역
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: controller.contentController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: null,
                  expands: true,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '오늘 어떤 일이 있었나요?',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.all(16),
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DiaryWriteButton(),
    );
  }
}