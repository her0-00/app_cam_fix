import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'raw_camera_plugin_platform_interface.dart';

/// An implementation of [RawCameraPluginPlatform] that uses method channels.
class MethodChannelRawCameraPlugin extends RawCameraPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('raw_camera_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
