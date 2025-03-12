import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login.dart';
import '../screens/home_screen.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString nickname = ''.obs;
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    _prefs ??= await SharedPreferences.getInstance();

    var savedNickname = _prefs?.getString('nickname') ?? '';

    // savedNickname 값 "" 로 초기화
    savedNickname = "";

    if (savedNickname.isNotEmpty) {
      nickname.value = savedNickname;
      isLoggedIn.value = true;
      Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn);
    } else {
      isLoggedIn.value = false;
      Get.offAll(() => LoginScreen(), transition: Transition.fadeIn);
    }
  }

  Future<void> login(String userNickname) async {

    if (userNickname.trim().isEmpty) {
      Get.snackbar(
        '로그인 실패',
        '닉네임을 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString('nickname', userNickname);
      nickname.value = userNickname;
      isLoggedIn.value = true;
      Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn);
    } catch (e) {
      Get.snackbar(
        '로그인 실패',
        '다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove('nickname');
    nickname.value = '';
    isLoggedIn.value = false;
    Get.offAll(() => LoginScreen(), transition: Transition.fadeIn);
  }
}