import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/image_loading_controller.dart';
import 'dart:async';
import '../styles/text_styles.dart';
import 'package:giraffe_diaries/models/model_load.dart';
import 'package:llama_library/llama_library.dart';
import '../screens/diary_screen.dart';

class ImageLoadingScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String contenttext;
  final String selectedStyle;

  const ImageLoadingScreen({
    super.key,
    required this.selectedDate,
    required this.contenttext,
    required this.selectedStyle,
  });

  @override
  State<ImageLoadingScreen> createState() => _ImageLoadingScreenState();
}

class _ImageLoadingScreenState extends State<ImageLoadingScreen> {
  late ImageGenerationController _controller;
  int _currentImageIndex = 1;
  late Timer _imageTimer;
  bool _isInitialized = false;
  late LlamaLibrary llamaLibrary;
  bool _isLoading = true;

  final List<String> _loadingTexts = [
    '기린이 일기를 읽고 있어요...',
    '잠시만 기다려주세요...',
    '조금만 더 기다려주세요...',
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    // 이미지 애니메이션 시작
    _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentImageIndex = _currentImageIndex == 6 ? 1 : _currentImageIndex + 1;
      });
    });

    // 텍스트 애니메이션 시작
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
    });

    // AI 이미지 생성 시작
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Get.isRegistered<ImageGenerationController>()) {
        Get.put(ImageGenerationController());
      }
      String encodetext = '';
      _controller = Get.find<ImageGenerationController>();
      DateTime llama_load_stime = DateTime.now();
      llamaLibrary = await modelLoad();
      DateTime llama_load_etime = DateTime.now();
      Duration llama_load_duration = llama_load_etime.difference(llama_load_stime);
      debugPrint('모델 로드 시간: ${llama_load_duration.inMilliseconds}ms');
      setState(() {
        _isLoading = false;
      });

      DateTime llama_send_stime = DateTime.now();
      //await _controller.llama_send_message(llamaLibrary, widget.contenttext, widget.selectedStyle);
      DateTime llama_send_etime = DateTime.now();
      Duration llama_send_duration = llama_send_etime.difference(llama_send_stime);
      debugPrint('모델 응답 시간: ${llama_send_duration.inMilliseconds}ms');
      
      Future.delayed(const Duration(milliseconds: 500));

      Get.off(DiaryScreen(
        selectedDate: widget.selectedDate, 
        contenttext: widget.contenttext,
        generatedImageUrl: '', 
        encodetext: encodetext,
        llamaLibrary: llamaLibrary
      ));
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/loading_images/giraffe_$_currentImageIndex.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 30),
            Text(
              _loadingTexts[_currentTextIndex],
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}