import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/home_loading.dart';
import 'services/diary_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 설정
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize DiaryService
  final diaryService = await DiaryService().init();
  Get.put(diaryService);

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