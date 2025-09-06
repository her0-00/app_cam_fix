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
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
        result(FlutterError(code: "CAMERA_ERROR", message: "Caméra non disponible", details: nil))
        return
      }

      if call.method == "setFPS" {
        guard let args = call.arguments as? [String: Any],
              let fps = args["fps"] as? Int else {
          result(FlutterError(code: "ARG_ERROR", message: "FPS manquant", details: nil))
          return
        }

        do {
          try device.lockForConfiguration()
          let frameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
          device.activeVideoMinFrameDuration = frameDuration
          device.activeVideoMaxFrameDuration = frameDuration
          device.automaticallyAdjustsVideoHDREnabled = false
          device.unlockForConfiguration()
          result("FPS réglé sur \(fps)")
        } catch {
          result(FlutterError(code: "CONFIG_ERROR", message: "Impossible de configurer la caméra", details: nil))
        }
      }

      else if call.method == "setStabilization" {
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
          result(FlutterError(code: "ARG_ERROR", message: "Paramètre manquant", details: nil))
          return
        }

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
          connection.preferredVideoStabilizationMode = enabled ? .standard : .off
        }

        session.commitConfiguration()
        result("Stabilisation \(enabled ? "activée" : "désactivée")")
      }

      else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
