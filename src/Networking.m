//
//  Networking.m
//  TraiBehind
//

#import "Networking.h"
#import "Strings.h"

@implementation Networking

+ (Networking*)sharedInstance {
  static Networking *sharedInstance = nil;
  @synchronized(self) {
    if (sharedInstance == nil) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
      sharedInstance = [[Networking alloc] init];
			[pool release];
    }
  }
  return sharedInstance;
}


- (void) reachabilityChanged: (NSNotification* )note {
}


- (void) foreground {
  [reachability startNotifier];
}


- (void) background {
  [reachability stopNotifier];
}


- (void) printStatus {
  NSLog(@"current reachability status %d", [reachability currentReachabilityStatus]);
}


- (id) init { 
  self = [super init];
  reachability = [[Reachability reachabilityWithHostName:@"www.google.com"] retain];
  [reachability performSelectorOnMainThread:@selector(startNotifier) withObject:nil waitUntilDone:NO];
  [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) 
                                               name: kReachabilityChangedNotification object:reachability];
  return self;
}

- (BOOL) canConnectToInternet {
	if ([reachability currentReachabilityStatus] == 0) {
		return NO;
	}		
	return YES;
}


NSDate* lastWarning;
// check if a server can be reached, and pop a warning if not
- (BOOL) canConnectToInternetWithWarning:(NSString*)message {
	if ([reachability currentReachabilityStatus] == 0) {
    int timeSince = 100;
    if (lastWarning) {
      timeSince = -[lastWarning timeIntervalSinceNow];
    }
    if (timeSince > 1) {
      [lastWarning release];
      lastWarning = [[NSDate date] retain];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet COnnection" 
                                                      message:message
                                                     delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
		return NO;
	}		
	return YES;
}


- (void) dealloc {
  [super dealloc];
}


@end
