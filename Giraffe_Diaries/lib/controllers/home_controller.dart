import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables
  final _count = 0.obs;

  // Getters
  int get count => _count.value;

  // Methods
  void increment() {
    _count.value++;
  }

  @override
  void onInit() {
    // Called when controller is initialized
    super.onInit();
  }

  @override
  void onClose() {
    // Called when controller is removed from memory
    super.onClose();
  }
}