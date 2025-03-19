import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giraffe_diaries/controllers/auth_controller.dart';
import 'dart:async';
import '../styles/text_styles.dart';
import '../models/model_download.dart';

class HomeLoadingScreen extends StatefulWidget {
  const HomeLoadingScreen({super.key});

  @override
  State<HomeLoadingScreen> createState() => _HomeLoadingScreenState();
}

class _HomeLoadingScreenState extends State<HomeLoadingScreen> {
  int _currentImageIndex = 1;
  late Timer _imageTimer;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _statusMessage = "모델 파일 확인 중...";

  @override
  void initState() {
    super.initState();
    // 이미지 애니메이션 시작

    
    _imageTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _currentImageIndex = _currentImageIndex == 2 ? 1 : _currentImageIndex + 1;
      });
    });

    // 모델 다운로드 시작
    _checkAndDownloadModel();
    //testllama();

  }

  Future<void> _checkAndDownloadModel() async {
    try {
      setState(() {
        _statusMessage = "모델 파일 확인 중...";
        _isDownloading = true;
      });

      final modelPath = await downloadModelFile(
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
            _statusMessage = "모델 다운로드 중...";
          });
        },
      );
      
      // 다운로드 완료 후 로그인 상태 확인
      _imageTimer.cancel();
      Get.put(AuthController());
    } catch (e) {
      setState(() {
        _statusMessage = "오류가 발생했습니다!";
        print("$_statusMessage: $e");
        _isDownloading = false;
      });
    }
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
              'assets/splash_images/giraffe$_currentImageIndex.jpg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 30),
            const Text(
              '네가그린기린일기',
              style: AppTextStyles.heading2,
            ),
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_isDownloading) ...[
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF6AD62)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      style: AppTextStyles.bodybold,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  if (!_isDownloading) ...[
                    const SizedBox(height: 5),
                    Text(
                      _statusMessage,
                      style: AppTextStyles.bodybold,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _checkAndDownloadModel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6AD62),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text('다시 시도', style: AppTextStyles.bodybold,),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 