import 'package:flutter/services.dart';

class NativeLibraryLoader {
  static const MethodChannel _channel = MethodChannel('native_library');

  static Future<void> loadNativeLibraries() async {
    try {
      await _channel.invokeMethod('loadCustomLibraries');
      print("Native libraries loaded successfully");
    } catch (e) {
      print("Failed to load native libraries: $e");
    }
  }
}