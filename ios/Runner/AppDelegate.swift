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
      if call.method == "configure240FPS" {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
          result(FlutterError(code: "CAMERA_ERROR", message: "Caméra non disponible", details: nil))
          return
        }

        do {
          var bestFormat: AVCaptureDevice.Format?
          var bestRange: AVFrameRateRange?

          for format in device.formats {
            for range in format.videoSupportedFrameRateRanges {
              if Int(range.maxFrameRate) == 240 {
                bestFormat = format
                bestRange = range
                break
              }
            }
            if bestFormat != nil { break }
          }

          guard let format = bestFormat, let range = bestRange else {
            result(FlutterError(code: "FPS_UNSUPPORTED", message: "240 FPS non pris en charge", details: nil))
            return
          }

          try device.lockForConfiguration()
          device.activeFormat = format
          device.activeVideoMinFrameDuration = range.minFrameDuration
          device.activeVideoMaxFrameDuration = range.minFrameDuration
          device.automaticallyAdjustsVideoHDREnabled = false
          device.unlockForConfiguration()
          result("✅ Caméra configurée à 240 FPS")
        } catch {
          result(FlutterError(code: "CONFIG_ERROR", message: "Impossible de configurer la caméra", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
