//
//  SWPTimeTableVC.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

@class SavingDictionary;
#import <MessageUI/MessageUI.h>

@interface SWPTimeTableVC : UITableViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate> { }

@property(nonatomic,retain) SavingDictionary *times;
@property(nonatomic,retain) UIViewController *presentingView;
@property(nonatomic,retain) NSMutableArray *cumulativeTotals;
@end
