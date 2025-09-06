import 'package:flutter/services.dart';

class RawCameraPlugin {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  static Future<String?> captureFrameWithoutOIS() async {
    final String? path = await _channel.invokeMethod('captureFrameWithoutOIS');
    return path;
  }
    /// Optionnel : récupérer la version de la plateforme
  static Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
