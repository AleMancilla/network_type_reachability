#import "NetworkTypeReachabilityPlugin.h"
#if __has_include(<network_type_reachability/network_type_reachability-Swift.h>)
#import <network_type_reachability/network_type_reachability-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "network_type_reachability-Swift.h"
#endif

@implementation NetworkTypeReachabilityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNetworkTypeReachabilityPlugin registerWithRegistrar:registrar];
}
@end
