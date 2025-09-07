#import "RawCameraPlugin.h"
#import "RawCameraViewFactory.h"

@implementation RawCameraPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  RawCameraViewFactory* factory = [[RawCameraViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:factory withId:@"raw_camera_plugin"];
}
@end
