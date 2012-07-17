//
//  SWPSettingsTableVC.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPTimeTableVC.h"
#import <MessageUI/MessageUI.h>

#define BUTTON_MODE_KEY @"buttonMode"
#define START_SPLIT_INDEX 1
#define START_STOP_INDEX 0

@interface SWPSettingsTableVC : SWPTimeTableVC <MFMailComposeViewControllerDelegate> { }

- (void) switchSkins;
- (void) showPledgeWall;

@end
