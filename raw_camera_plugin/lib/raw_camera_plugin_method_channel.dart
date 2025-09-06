import 'package:flutter/services.dart';

class RawCameraPluginObjC {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  static Future<String?> captureRawPhoto() async {
    final String? path = await _channel.invokeMethod('captureRawPhoto');
    return path;
  }
}
