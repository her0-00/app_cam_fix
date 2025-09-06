
import 'raw_camera_plugin_platform_interface.dart';
import 'package:flutter/services.dart';
class RawCameraPlugin {
  Future<String?> getPlatformVersion() {
    return RawCameraPluginPlatform.instance.getPlatformVersion();
  }
}


class RawCameraPluginObjC {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  static Future<String?> captureRawPhoto() async {
    final String? path = await _channel.invokeMethod('captureRawPhoto');
    return path;
  }
}
