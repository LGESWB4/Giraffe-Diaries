import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login.dart';
import '../screens/home_screen.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString userName = ''.obs;
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
    final savedusername = _prefs?.getString('username') ?? '';

    if (savedusername.isNotEmpty) {
      userName.value = savedusername;
      isLoggedIn.value = true;
      Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn);
    } else {
      isLoggedIn.value = false;
      Get.offAll(() => LoginScreen(), transition: Transition.fadeIn);
    }
  }

  Future<void> login(String username) async {

    if (username.trim().isEmpty) {
      Get.snackbar(
        '로그인 실패',
        '닉네임을 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString('username', username);
      userName.value = username;
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

    //await _prefs?.remove('username');

    userName.value = '';
    isLoggedIn.value = false;
    Get.offAll(() => LoginScreen(), transition: Transition.fadeIn);
  }
}