import 'package:flutter/services.dart';

class RawCameraPlugin {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  static Future<String?> captureHighQualityPhoto() async {
    final String? path = await _channel.invokeMethod('captureHighQualityPhoto');
    return path;
  }

  static void setSensorReadyHandler(Function() onReady) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sensorReady') {
        onReady();
      }
    });
  }

    /// Optionnel : récupérer la version de la plateforme
  static Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
