import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/style_select_controller.dart';
import '../widgets/style_item.dart';
import '../styles/text_styles.dart';
import '../widgets/exit_confirmation_dialog.dart';

class StyleSelectScreen extends GetView<StyleSelectController> {
  final DateTime selectedDate;
  final String contenttext;

  const StyleSelectScreen({
    super.key,
    required this.selectedDate,
    required this.contenttext,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(StyleSelectController(selectedDate: selectedDate, contenttext: contenttext));

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
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.dialog(const ExitConfirmationDialog(), barrierDismissible: false,),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
            child: Column(
              children: [
                Text(
                  '원하는 그림 스타일을\n선택해주세요',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '기본은 수채화 스타일입니다',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: controller.styles.length,
                itemBuilder: (context, index) {
                  return Obx(() => StyleItem(
                    name: controller.styles[index]['name']!,
                    imagePath: controller.styles[index]['image']!,
                    isSelected: controller.selectedStyle.value == index,
                    onTap: () => controller.selectStyle(index),
                  ));
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
            child: Column(
              children: [
                Obx(() => ElevatedButton(
                  onPressed: controller.selectedStyle.value >= 0
                      ? controller.confirmSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6AD62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text(
                    '선택 완료',
                    style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                  ),
                )),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextButton(
                    onPressed: controller.skipSelection,
                    child: Text(
                      '건너뛰기',
                      style: AppTextStyles.bodyMedium.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}