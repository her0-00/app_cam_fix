#import "RawCameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface RawCameraPlugin () <FlutterPlugin, AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDeviceInput *input;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong) FlutterResult resultCallback;
@property(nonatomic, assign) BOOL hasCaptured;
@property(nonatomic, assign) int frameCount;
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
  if ([@"captureFrameWithoutOIS" isEqualToString:call.method]) {
    self.resultCallback = result;
    self.hasCaptured = NO;
    self.frameCount = 0;
    [self setupVideoCapture];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setupVideoCapture {
  self.session = [[AVCaptureSession alloc] init];
  self.session.sessionPreset = AVCaptureSessionPresetHigh;

  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *error = nil;
  self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

  if ([self.session canAddInput:self.input]) {
    [self.session addInput:self.input];
  }

  self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
  self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
  [self.videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

  if ([self.session canAddOutput:self.videoOutput]) {
    [self.session addOutput:self.videoOutput];
  }

  [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

  self.frameCount++;
  if (self.frameCount < 5 || self.hasCaptured) return;
  self.hasCaptured = YES;

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
  CIContext *context = [CIContext contextWithOptions:nil];
  CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];

  if (!cgImage) {
    self.resultCallback([FlutterError errorWithCode:@"IMAGE_ERROR" message:@"Image non extraite" details:nil]);
    return;
  }

  UIImage *image = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);

  NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"frame.jpg"];
  [imageData writeToFile:path atomically:YES];

  [self.session stopRunning];
  self.resultCallback(path);
}
@end
