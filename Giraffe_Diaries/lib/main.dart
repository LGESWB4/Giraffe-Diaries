import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/home_loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 기본 스플래시 화면 숨기기
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [],
  );
  // GetX 컨트롤러 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '네가그린기린일기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        fontFamily: 'AppleSDGothicNeoM',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w600),
          displayMedium: TextStyle(fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      home: const HomeLoadingScreen(),
    );
  }
}