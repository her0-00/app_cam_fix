
import 'raw_camera_plugin_platform_interface.dart';

class RawCameraPlugin {
  Future<String?> getPlatformVersion() {
    return RawCameraPluginPlatform.instance.getPlatformVersion();
  }
}
