import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "camfixxr/camera", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "configureCamera" {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
          result(FlutterError(code: "CAMERA_ERROR", message: "Caméra non disponible", details: nil))
          return
        }

        do {
          try device.lockForConfiguration()
          device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 15) // 15 FPS
          device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15)
          device.automaticallyAdjustsVideoHDREnabled = false
          device.automaticallyAdjustsVideoStabilizationMode = false
          device.unlockForConfiguration()
          result("Configuration appliquée")
        } catch {
          result(FlutterError(code: "CONFIG_ERROR", message: "Impossible de configurer la caméra", details: nil))
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
