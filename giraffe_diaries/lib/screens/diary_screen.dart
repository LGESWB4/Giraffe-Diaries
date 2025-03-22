import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giraffe_diaries/screens/home_screen.dart';
import 'package:giraffe_diaries/screens/style_select_screen.dart';
import 'package:giraffe_diaries/services/diary_service.dart';
import '../styles/text_styles.dart';
import 'chat_dialog.dart';
import '../models/model_load.dart';
import 'package:llama_library/llama_library.dart';
import '../models/model_send.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String contenttext;
  final String emojiImagePath;
  final String selectedStyle;
  final String generatedImageUrl;
  const DiaryScreen({
    super.key,
    required this.selectedDate,
    required this.contenttext,
    required this.emojiImagePath,
    required this.selectedStyle,
    required this.generatedImageUrl,
  });

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String generatedImageUrl = '';
  final LlamaLibraryChatHistory _chatHistory = LlamaLibraryChatHistory();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool isImageLoaded = false;
  bool isFirstLoaded = true;


  @override
  void initState() {
    super.initState();
    // 초기 인사 메시지
    _checkImageLoaded().then((_) {
      setState(() {
        isFirstLoaded = false;
      });
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
      
    //   _chatHistory.clear();
      
    //   String response = '';
    //   response = await chatmessage(widget.contenttext, Get.find<LlamaLibrary>(), false, _chatHistory, (String modelres) {
    //     debugPrint("modelres: $modelres");
    //   });
    //   _messages.add({
    //     'sender': 'giraffe',
    //     'message': response,
    //   });
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });


  }

  @override
  void dispose() {
    Get.find<LlamaLibrary>().dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    if (widget.generatedImageUrl == '') {
      return;
    }

    try {
      final diaryService = Get.find<DiaryService>();
      print("다이어리 서비스 가져옴");

      // 이미지 URL에서 이미지 데이터 다운로드
      final response = await http.get(Uri.parse(widget.generatedImageUrl));

      if (response.statusCode == 200) {
        // Pictures 디렉토리 가져오기
        final directory = await getExternalStorageDirectory();
        final picturesDir = Directory('${directory?.path}/Pictures');

        // Pictures 디렉토리가 없으면 생성
        if (!await picturesDir.exists()) {
          await picturesDir.create(recursive: true);
        }

        final fileName =
            "giraffe_diary_${widget.selectedDate.year}${widget.selectedDate.month}${widget.selectedDate.day}.png";
        final file = File('${picturesDir.path}/$fileName');

        // 이미지 데이터를 파일로 저장
        await file.writeAsBytes(response.bodyBytes);

        // 미디어 스캔을 위해 플랫폼 채널 호출
        await const MethodChannel(
          'giraffe_diaries',
        ).invokeMethod('scanFile', {'path': file.path});

        Get.snackbar(
          '저장 완료',
          '이미지가 갤러리에 저장되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('이미지 다운로드 실패');
      }
    } catch (e) {
      Get.snackbar(
        '저장 실패',
        '이미지 저장 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('이미지 저장 오류: $e');
    }
  }

  void _showImageDetail(BuildContext context) {
    if (widget.generatedImageUrl == '') {
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save_alt, color: Colors.black),
                          onPressed: _saveImage,
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
                      child: Image.network(
                        widget.generatedImageUrl,
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

  Widget _buildImage() {
    if (widget.selectedStyle == '') {
      return GestureDetector(
        onTap: () {
          Get.to(
            () => StyleSelectScreen(
              selectedDate: widget.selectedDate,
              contenttext: widget.contenttext,
            ),
          );
        }, // Image tapped
        child: Image.asset(
          "assets/images/choose_style.png",
          fit: BoxFit.contain,
        ),
      );
    } else {
      return GestureDetector(
        onTap: _checkImageLoaded,
        child: Image.asset(
          "assets/images/image_generating.png",
          fit: BoxFit.contain,
        ),
      );
    }
  }

  Future<void> _checkImageLoaded() async {
    if (widget.generatedImageUrl == '') {
      return;
    }
    try {
      final requestUrl = widget.generatedImageUrl.replaceAll(
        '/image',
        '/image/check',
      );
      print("requestUrl: $requestUrl");
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      print("data: $data");
      final isIageExisted = data['file_exists'];
      if (isIageExisted) {
        setState(() {
          isImageLoaded = true;
        });
        print("Image request successful, isImageLoaded set to false");
      } else {
        print("Image request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during image request: $e");
    }
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
            onPressed: _saveImage,
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // TODO: 메뉴 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.offAll(const HomeScreen()),
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
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이모지와 날짜
                Center(
                  child: Column(
                    children: [
                      Image.asset(widget.emojiImagePath, width: 80, height: 80),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
                        style: AppTextStyles.heading1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // 생성된 이미지
                Center(
                  child:
                      isFirstLoaded
                          ? SizedBox(width: 300, height: 300)
                          : SizedBox(
                            width: 300,
                            height: 300,
                            child: GestureDetector(
                              onTap: () => _showImageDetail(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child:
                                    isImageLoaded
                                        ? Image.network(
                                          widget.generatedImageUrl,
                                          fit: BoxFit.cover,
                                        )
                                        : _buildImage(),
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
                      widget.contenttext,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 기린과 대화하기 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder:
                          (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: ChatDialog(
                              selectedDate: widget.selectedDate,
                              contenttext: widget.contenttext,
                              chatHistory: _chatHistory,
                              messages: _messages,
                            ),
                          ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Color(0xFFE5E5E5) : const Color(0xFFF6AD62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _isLoading ? '기린이 준비중...' : '기린과 대화할래?',
                    style: AppTextStyles.buttonText.copyWith(
                      color: _isLoading ? Colors.black : Colors.white,
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
