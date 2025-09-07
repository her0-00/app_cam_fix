#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface RawCameraViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
