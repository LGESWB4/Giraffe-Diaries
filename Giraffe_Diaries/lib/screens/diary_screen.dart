import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../styles/text_styles.dart';
import 'chat_dialog.dart';

class DiaryScreen extends StatelessWidget {
  final String generatedImageUrl;
  final String diaryContent = "오늘도 chill 하게 살아간다";
  final List<String> hashtags = ['멋짐', '자신감'];
  final String emojiImage = 'assets/emoji_images/cool_emoji.jpg';
  final DateTime selectedDate;

  DiaryScreen({
    Key? key,
    required this.generatedImageUrl,
    required this.selectedDate,
  }) : super(key: key);

  void _showImageDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save_alt, color: Colors.black),
                      onPressed: () {
                        // TODO: 이미지 저장 기능 구현
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    generatedImageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.black),
            onPressed: () {
              // TODO: 저장 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // TODO: 메뉴 기능 구현
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이모지와 날짜
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        emojiImage,
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                        style: AppTextStyles.heading1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // 해시태그
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: hashtags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 생성된 이미지
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    child: GestureDetector(
                      onTap: () => _showImageDetail(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          generatedImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 일기 내용
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      diaryContent,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 기린과 대화하기 버튼
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: ChatDialog(selectedDate: selectedDate),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6AD62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    '기린과 대화할래?',
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 