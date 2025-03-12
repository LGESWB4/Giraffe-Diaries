import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'login.dart';

class HomeLoadingScreen extends StatefulWidget {
  const HomeLoadingScreen({super.key});

  @override
  State<HomeLoadingScreen> createState() => _HomeLoadingScreenState();
}

class _HomeLoadingScreenState extends State<HomeLoadingScreen> {
  int _currentImageIndex = 1;
  late Timer _imageTimer;

  @override
  void initState() {
    super.initState();
    // 이미지 애니메이션 시작
    _imageTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _currentImageIndex = _currentImageIndex == 2 ? 1 : _currentImageIndex + 1;
      });
    });

    // 3초 후 로그인 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      _imageTimer.cancel();
      Get.off(() => LoginScreen());
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
              'assets/splash_images/giraffe$_currentImageIndex.jpg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 30),
            const Text(
              '네가그린기린일기',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 