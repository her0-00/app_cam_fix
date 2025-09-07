#import "RawCameraViewFactory.h"
#import "RawCameraView.h"

@implementation RawCameraViewFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id)args {
  return [[RawCameraView alloc] initWithFrame:frame viewIdentifier:viewId messenger:_messenger];
}

@end
