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

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else {
        result(FlutterError(code: "SELF_ERROR", message: "Référence perdue", details: nil))
        return
      }

      if call.method == "activateRealSpaceMode" {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
          result(FlutterError(code: "CAMERA_ERROR", message: "Caméra non disponible", details: nil))
          return
        }

        do {
          let (format, range) = try self.selectNeutralFormat(device: device)

          try device.lockForConfiguration()
          device.activeFormat = format
          device.activeVideoMinFrameDuration = range.minFrameDuration
          device.activeVideoMaxFrameDuration = range.minFrameDuration
          device.automaticallyAdjustsVideoHDREnabled = false
          device.unlockForConfiguration()

          let session = AVCaptureSession()
          session.beginConfiguration()

          guard let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input) else {
            result(FlutterError(code: "SESSION_ERROR", message: "Impossible d’ajouter l’entrée", details: nil))
            return
          }

          session.addInput(input)

          let output = AVCaptureVideoDataOutput()
          if session.canAddOutput(output) {
            session.addOutput(output)
          }

          if let connection = output.connection(with: .video) {
            connection.preferredVideoStabilizationMode = .off
          }

          session.commitConfiguration()
          result("✅ Mode brut activé avec format : \(format.formatDescription)")
        } catch {
          result(FlutterError(code: "CONFIG_ERROR", message: error.localizedDescription, details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func selectNeutralFormat(device: AVCaptureDevice) throws -> (AVCaptureDevice.Format, AVFrameRateRange) {
    for format in device.formats {
      for range in format.videoSupportedFrameRateRanges {
        let isNeutral = format.isVideoStabilizationSupported == false &&
                        Int(range.maxFrameRate) == 30 &&
                        Int(range.minFrameRate) <= 30

        if isNeutral {
          return (format, range)
        }
      }
    }
    throw NSError(domain: "FORMAT_ERROR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Aucun format neutre trouvé"])
  }
}
