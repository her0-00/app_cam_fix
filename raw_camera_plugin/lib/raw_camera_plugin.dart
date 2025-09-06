import 'package:flutter/services.dart';

class RawCameraPlugin {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  /// Capture une photo RAW (.dng) via le plugin natif
  static Future<String?> captureRawPhoto() async {
    final String? path = await _channel.invokeMethod('captureRawPhoto');
    return path;
  }

  /// Optionnel : récupérer la version de la plateforme
  static Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
