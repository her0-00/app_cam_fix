import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class RawCameraPlugin {
  static const MethodChannel _channel = MethodChannel('raw_camera_plugin');

  static Future<void> captureRawPhoto() async {
    await _channel.invokeMethod('captureRawPhoto');
  }

  static void setRawPhotoCapturedHandler(Function(String path) onCaptured) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'rawPhotoCaptured') {
        onCaptured(call.arguments as String);
      }
    });
  }
}

class RawCameraPreview extends StatelessWidget {
  const RawCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const UiKitView(
      viewType: 'raw_camera_plugin',
      layoutDirection: TextDirection.ltr,
    );
  }
}
