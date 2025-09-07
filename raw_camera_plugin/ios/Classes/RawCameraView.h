#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface RawCameraView : NSObject <FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    messenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
