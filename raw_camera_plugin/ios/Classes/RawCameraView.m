#import "RawCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface RawCameraView () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, strong) UIView* containerView;
@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property(nonatomic, strong) AVCaptureVideoDataOutput* videoOutput;
@property(nonatomic, strong) AVCaptureDevice* device;
@property(nonatomic, strong) FlutterMethodChannel* channel;
@property(nonatomic, assign) BOOL shouldCapture;
@end

@implementation RawCameraView

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _containerView = [[UIView alloc] initWithFrame:frame];
    _channel = [FlutterMethodChannel methodChannelWithName:@"raw_camera_plugin" binaryMessenger:messenger];
    [self setupCamera];
  }
  return self;
}

- (UIView*)view {
  return _containerView;
}

- (void)setupCamera {
  _session = [[AVCaptureSession alloc] init];
  _session.sessionPreset = AVCaptureSessionPresetHigh;

  _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDeviceFormat *format in _device.formats) {
    CMFormatDescriptionRef desc = format.formatDescription;
    CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(desc);
    for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
      if (dims.width == 1920 && range.maxFrameRate >= 240) {
        [_device lockForConfiguration:nil];
        _device.activeFormat = format;
        _device.activeVideoMinFrameDuration = CMTimeMake(1, 240);
        _device.activeVideoMaxFrameDuration = CMTimeMake(1, 240);
        [_device unlockForConfiguration];
        break;
      }
    }
  }

  NSError *error = nil;
  AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
  if ([_session canAddInput:input]) {
    [_session addInput:input];
  }

  _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
  [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
  if ([_session canAddOutput:_videoOutput]) {
    [_session addOutput:_videoOutput];
  }

  _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
  _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  _previewLayer.frame = _containerView.bounds;
  [_containerView.layer addSublayer:_previewLayer];

  [_session startRunning];

  [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([call.method isEqualToString:@"captureRawPhoto"]) {
      self->_shouldCapture = YES;
      result(nil);
    }
  }];
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
  if (!_shouldCapture) return;
  _shouldCapture = NO;

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
  CIContext *context = [CIContext contextWithOptions:nil];
  CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
  UIImage *image = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);

  NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"raw_frame.jpg"];
  [imageData writeToFile:path atomically:YES];
  [_channel invokeMethod:@"rawPhotoCaptured" arguments:path];
}

@end
