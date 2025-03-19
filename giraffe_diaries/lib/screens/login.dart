import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../styles/text_styles.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final nicknameController = TextEditingController();
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash_images/giraffe1.jpg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                '내 이름은 기린! 넌?',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  labelStyle: AppTextStyles.bodyMedium,
                  hintText: '사용하실 닉네임을 입력해주세요',
                  hintStyle: AppTextStyles.bodyMedium,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFF6AD62), width: 2),
                  ),
                ),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    authController.login(nicknameController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6AD62),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    '시작하기',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 