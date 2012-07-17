//
//  Networking.h
//  TrailBehind
//

#import "Reachability.h"

@interface Networking : NSObject {
  Reachability* reachability;
}

+ (Networking*)sharedInstance;
- (BOOL) canConnectToInternet;
- (BOOL) canConnectToInternetWithWarning:(NSString*)message;

@end

