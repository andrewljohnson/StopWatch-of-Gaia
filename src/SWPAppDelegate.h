//
//  SWPAppDelegate.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

@class SWPViewController, SWPSettingsTableVC, SWPPledgeTable, SWPPurchaseController;

@interface SWPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SWPViewController *viewController;
@property (nonatomic, retain) SWPPledgeTable *pledgeTable;
@property (nonatomic, retain) SWPSettingsTableVC *settingsScreen;
@property (nonatomic, retain) SWPPurchaseController *purchaseController;

@end
