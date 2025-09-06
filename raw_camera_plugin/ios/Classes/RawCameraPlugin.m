#import "RawCameraPlugin.h"
#import <AVFoundation/AVFoundation.h>

@interface RawCameraPlugin () <FlutterPlugin, AVCapturePhotoCaptureDelegate>
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDeviceInput *input;
@property(nonatomic, strong) AVCapturePhotoOutput *output;
@property(nonatomic, strong) FlutterResult resultCallback;
@end

@implementation RawCameraPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"raw_camera_plugin"
            binaryMessenger:[registrar messenger]];
  RawCameraPlugin* instance = [[RawCameraPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"captureRawPhoto" isEqualToString:call.method]) {
    self.resultCallback = result;
    [self setupCameraAndCapture];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setupCameraAndCapture {
  if (self.session.isRunning) {
    [self.session stopRunning];
  }

  self.session = [[AVCaptureSession alloc] init];
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *error = nil;
  self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
  self.output = [[AVCapturePhotoOutput alloc] init];

  if ([self.session canAddInput:self.input]) {
    [self.session addInput:self.input];
  }
  if ([self.session canAddOutput:self.output]) {
    [self.session addOutput:self.output];
  }

  [self.session startRunning];

  if (self.output.availableRawPhotoPixelFormatTypes.count > 0) {
    NSNumber *rawFormat = self.output.availableRawPhotoPixelFormatTypes.firstObject;
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithRawPixelFormatType:rawFormat.intValue];
    settings.flashMode = AVCaptureFlashModeOff;
    settings.highResolutionPhotoEnabled = YES;
    [self.output capturePhotoWithSettings:settings delegate:self];
  } else {
    self.resultCallback([FlutterError errorWithCode:@"RAW_UNAVAILABLE" message:@"RAW format non disponible" details:nil]);
  }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhoto:(AVCapturePhoto *)photo
               error:(nullable NSError *)error {
  if (error) {
    self.resultCallback([FlutterError errorWithCode:@"CAPTURE_ERROR" message:error.localizedDescription details:nil]);
    return;
  }

  NSData *rawData = photo.fileDataRepresentation;
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"photo.dng"];
  [rawData writeToFile:path atomically:YES];
  self.resultCallback(path);
}
@end
