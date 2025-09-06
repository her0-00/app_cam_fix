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
      if call.method == "activateRawMode" {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
          result(FlutterError(code: "CAMERA_ERROR", message: "Caméra non disponible", details: nil))
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
          connection.preferredVideoStabilizationMode = .off // ❌ EIS désactivée
        }

        do {
          try device.lockForConfiguration()
          device.automaticallyAdjustsVideoHDREnabled = false // ❌ HDR désactivé
          device.unlockForConfiguration()
        } catch {
          result(FlutterError(code: "CONFIG_ERROR", message: "Impossible de configurer la caméra", details: nil))
          return
        }

        session.commitConfiguration()
        result("✅ Mode brut activé")
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
