import 'package:flutter/material.dart';
import 'dart:async';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  int _currentImageIndex = 1;
  int _dotCount = 1;
  late Timer _imageTimer;
  late Timer _dotTimer;

  @override
  void initState() {
    super.initState();
    // 이미지 애니메이션 타이머
    _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentImageIndex = _currentImageIndex == 6 ? 1 : _currentImageIndex + 1;
      });
    });

    // 점(...) 애니메이션 타이머
    _dotTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    _dotTimer.cancel();
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
              'AI가 그림 그리는 중${'.' * _dotCount}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 