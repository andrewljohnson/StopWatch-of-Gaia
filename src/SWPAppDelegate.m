//
//  SWPAppDelegate.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPAppDelegate.h"
#import "SWPViewController.h"
#import "SWPConstants.h"
#import "SWPSettingsTableVC.h"
#import "SWPPledgeTable.h"
#import "SWPPurchaseController.h"

// trailbehind code
#import "Networking.h"
#import "SavingDictionary.h"

// 3rd party libraries
#import <Parse/Parse.h>
#import "Crittercism.h"

// Apple libraries
#import <StoreKit/StoreKit.h>


@implementation SWPAppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize settingsScreen, pledgeTable, purchaseController;

- (void)dealloc {
  [_window release];
  [pledgeTable release];
  [_viewController release];
  [purchaseController release];
  [super dealloc];
}


- (SWPPledgeTable*) pledgeTable {
  if (pledgeTable) {
    return pledgeTable;
  }
  pledgeTable = [[SWPPledgeTable alloc]initWithStyle:UITableViewStyleGrouped];
  return pledgeTable;
}


- (void) initLibraries {
  [Parse setApplicationId:PARSE_APP_ID
                clientKey:PARSE_CLIENT_KEY];
  [Crittercism initWithAppID:CRITTER_APP_ID
                      andKey:CRITTER_KEY
                   andSecret:CRITTER_KEY_SECRET];
  [Networking sharedInstance];

}


- (void) setupView {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.settingsScreen = [[[SWPSettingsTableVC alloc]initWithStyle:UITableViewStyleGrouped]autorelease];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.viewController = [[[SWPViewController alloc] initWithNibName:@"SWPViewController_iPhone" bundle:nil] autorelease];
  } else {
    self.viewController = [[[SWPViewController alloc] initWithNibName:@"SWPViewController_iPad" bundle:nil] autorelease];
  }
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self initLibraries];
  SavingDictionary *sd = [[[SavingDictionary alloc]initWithClass:[SWPSettingsTableVC class]]autorelease];
  if(![sd objectForKey:@"SOUND_ENABLED"]) {
    [sd setObject:N(YES) forKey:@"SOUND_ENABLED"];
  }
  [self setupView];
  self.purchaseController = [[[SWPPurchaseController alloc]init]autorelease];
  [self.purchaseController fetchProducts];
  [self.purchaseController comeOnPromptMeMaybe];
  return YES;
}


@end
