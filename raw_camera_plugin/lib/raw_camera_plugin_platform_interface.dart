import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'raw_camera_plugin_method_channel.dart';

abstract class RawCameraPluginPlatform extends PlatformInterface {
  /// Constructs a RawCameraPluginPlatform.
  RawCameraPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static RawCameraPluginPlatform _instance = MethodChannelRawCameraPlugin();

  /// The default instance of [RawCameraPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelRawCameraPlugin].
  static RawCameraPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RawCameraPluginPlatform] when
  /// they register themselves.
  static set instance(RawCameraPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
