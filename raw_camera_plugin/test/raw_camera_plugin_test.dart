import 'package:flutter_test/flutter_test.dart';
import 'package:raw_camera_plugin/raw_camera_plugin.dart';
import 'package:raw_camera_plugin/raw_camera_plugin_platform_interface.dart';
import 'package:raw_camera_plugin/raw_camera_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRawCameraPluginPlatform
    with MockPlatformInterfaceMixin
    implements RawCameraPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RawCameraPluginPlatform initialPlatform = RawCameraPluginPlatform.instance;

  test('$MethodChannelRawCameraPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRawCameraPlugin>());
  });

  test('getPlatformVersion', () async {
    RawCameraPlugin rawCameraPlugin = RawCameraPlugin();
    MockRawCameraPluginPlatform fakePlatform = MockRawCameraPluginPlatform();
    RawCameraPluginPlatform.instance = fakePlatform;

    expect(await rawCameraPlugin.getPlatformVersion(), '42');
  });
}
