#import "RawCameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface RawCameraPlugin () <FlutterPlugin, AVCapturePhotoCaptureDelegate>
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDeviceInput *input;
@property(nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property(nonatomic, strong) FlutterResult resultCallback;
@property(nonatomic, strong) AVCaptureDevice *device;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation RawCameraPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"raw_camera_plugin"
            binaryMessenger:[registrar messenger]];
  RawCameraPlugin* instance = [[RawCameraPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"captureHighQualityPhoto" isEqualToString:call.method]) {
    self.resultCallback = result;
    [self setupCameraAndCapture];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setupCameraAndCapture {
  self.session = [[AVCaptureSession alloc] init];
  self.session.sessionPreset = AVCaptureSessionPresetPhoto;

  self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *error = nil;
  self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
  self.photoOutput = [[AVCapturePhotoOutput alloc] init];

  if ([self.session canAddInput:self.input]) {
    [self.session addInput:self.input];
  }
  if ([self.session canAddOutput:self.photoOutput]) {
    [self.session addOutput:self.photoOutput];
  }

  [self.session startRunning];

  // 🔍 Mise au point au centre
  if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
    [self.device unlockForConfiguration];
  }

  // ✅ Attendre que le capteur soit prêt
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.channel invokeMethod:@"sensorReady" arguments:nil];
  });
}

- (void)capturePhoto {
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  settings.highResolutionPhotoEnabled = YES;
  settings.flashMode = AVCaptureFlashModeAuto;
  [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhoto:(AVCapturePhoto *)photo
               error:(nullable NSError *)error {
  if (error) {
    self.resultCallback([FlutterError errorWithCode:@"CAPTURE_ERROR" message:error.localizedDescription details:nil]);
    return;
  }

  NSData *imageData = [photo fileDataRepresentation];
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"photo.jpg"];
  [imageData writeToFile:path atomically:YES];
  [self.session stopRunning];
  self.resultCallback(path);
}
@end
