//
//  SWPSettingsTableVC.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPSettingsTableVC.h"
#import "SWPConstants.h"
#import "SWPViewCOntroller.h"
#import "SWPAppDelegate.h"
#import "SWPPledgeWall.h"
#import "SWPStyle.h"

#import "SavingDictionary.h"
#import "Networking.h"
#import "RoundedGradientCellBackground.h"

#import <StoreKit/StoreKit.h>
#import <Twitter/Twitter.h>


#define PLEDGE_SECTION 0
#define SETTINGS_SECTION 1
#define BUTTON_SECTION 2
#define CONTACT_SECTION 3

#define EMAIL_FRIEND_SECTION 1

#define CONTACT_US_INDEX 0
#define EMAIL_APP_INDEX 1
#define TWEET_US_INDEX 2

#define SKIN_INDEX 1
#define SOUND_INDEX 0


@implementation SWPSettingsTableVC

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    SavingDictionary *settingsDict = SETTINGS_DICT;    
    if (![settingsDict objectForKey:BUTTON_MODE_KEY]) {
      [settingsDict setObject:N(START_STOP_INDEX) forKey:BUTTON_MODE_KEY];
    }
  }
  return self;
}


- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.tableView reloadData];
}


- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem = nil;
  self.title = @"Settings";
  [self switchSkins];
}


- (void)viewDidUnload {
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
  if (result == MFMailComposeResultSent) { }
  [self dismissModalViewControllerAnimated:YES];
}


- (void) contactUs {
  NSString *subject = @"StopWatch+ Feedback";
	MFMailComposeViewController* controller = [[[MFMailComposeViewController alloc] init]autorelease];
	controller.mailComposeDelegate = self;
	[controller setSubject:subject];
	[controller setToRecipients:[NSArray arrayWithObject:@"stopwatch@gaiagps.com"]];
	[self presentModalViewController:controller animated:YES];
}


- (void) emailFriend {
  NSString *subject = @"Check Out StopWatch+";
	MFMailComposeViewController* controller = [[[MFMailComposeViewController alloc] init]autorelease];
	controller.mailComposeDelegate = self;
	[controller setSubject:subject];
  NSString *appStoreURL = @"http://itunes.apple.com/us/app/gaia-gps/id329127297?mt=8";
  NSString *body = [NSString stringWithFormat:@"Check out StopWatch+. It's a great app for your iPhone that records time in an amazing way. <a href=%@>You can download it from iTunes</a>.", appStoreURL];
  [controller setMessageBody:body isHTML:YES];
		[self presentModalViewController:controller animated:YES];
}


- (void) tweetStopwatch {
	// Set up the built-in twitter composition view controller.
	TWTweetComposeViewController *tweetViewController = [[[TWTweetComposeViewController alloc]init]autorelease];
	UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:tweetViewController]autorelease];
	[nav setNavigationBarHidden:YES animated:NO];
	
	// Set the initial tweet text. See the framework for additional properties that can be set.
	[tweetViewController setInitialText:[NSString stringWithFormat:@"I just used StopWatch+ on the iPhone: %@", @"http://itunes.apple.com/us/app/stopwatch+/id518178439?mt=8"]];
	
	// Create the completion handler block.
	[tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {        
		// Dismiss the tweet composition view controller.
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	// Present the tweet composition view controller modally.
	[self presentModalViewController:nav animated:YES];	

}


- (void) showPledgeWall {
  if (![[Networking sharedInstance]canConnectToInternetWithWarning:@"You need an internet connection to see the pledge wall"]) {
    return;
  }
  SWPPledgeWall *table = [[[SWPPledgeWall alloc]initWithStyle:UITableViewStyleGrouped]autorelease];
  [self.navigationController pushViewController:table animated:YES];
}


- (void) toggleSound {
  SavingDictionary *sd = [[[SavingDictionary alloc]initWithClass:[SWPSettingsTableVC class]]autorelease];
  if([[sd objectForKey:@"SOUND_ENABLED"] isEqual:N(YES)]) {
    [sd setObject:N(NO) forKey:@"SOUND_ENABLED"];
    return;
  }
  [sd setObject:N(YES) forKey:@"SOUND_ENABLED"];
}


- (void) switchSkins {
  [SWPStyle setStyleForNavBar:self.navigationController.navigationBar];
  [self.tableView reloadData];
}


//- (void) restorePurchases {
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//}


#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 4; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case PLEDGE_SECTION:
      // pledge wall
      return 1;
      break;
    case SETTINGS_SECTION:
      // skin and sound
      if ([SETTINGS_DICT objectForKey:BOWSER_PURCHASED]) {
        return 2;
      }
      return 1;      
      break;
    case CONTACT_SECTION:
      // contact us
      return 3;
      break;
    case BUTTON_SECTION:
      // button mode
      return 2;      
      break;
    default:
      return 0;     
      break;
  }
}


- (void) setCell:(UITableViewCell*)cell forIndex:(int)index title:(NSString*)title {
  cell.textLabel.text = title;  
  if ([[SETTINGS_DICT objectForKey:BUTTON_MODE_KEY]intValue] == index) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;        
  }  
}


- (UISwitch*) addSwitchWithAction:(NSString*)action cell:(UITableViewCell*)cell {
	UISwitch *sw = [[[UISwitch alloc] init]autorelease];
	sw.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; 
	sw.frame = CGRectMake(cell.contentView.frame.size.width-sw.frame.size.width-5, 
                        12, 
                        sw.frame.size.width-15-10, 
                        sw.frame.size.height);
	[sw addTarget:self 
         action:NSSelectorFromString(action) 
forControlEvents:UIControlEventValueChanged];
	[cell.contentView addSubview:sw];
	return sw;  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *CellIdentifier = @"SettingsCell";
  UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
  RoundedGradientCellBackground *bgView;
  if (cell == nil) {
    bgView = [[[RoundedGradientCellBackground alloc] initWithFrame:CGRectZero]autorelease];
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   cell.backgroundView = bgView;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth; 
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth; 
        
  }
  cell.textLabel.textColor = [SWPStyle textColor];
  cell.textLabel.shadowColor = [UIColor blackColor];
  bgView = (RoundedGradientCellBackground*)cell.backgroundView;
  int row = indexPath.row;
  if (indexPath.section == PLEDGE_SECTION) {
    bgView.position = UACellBackgroundViewPositionSingle;
  } else if (indexPath.section == SETTINGS_SECTION) {
    if (![SETTINGS_DICT objectForKey:BOWSER_PURCHASED]) {
      bgView.position = UACellBackgroundViewPositionSingle;
    } else if (row == 0) {
      bgView.position = UACellBackgroundViewPositionTop;
    } else {
      bgView.position = UACellBackgroundViewPositionBottom;      
    }
  } else if (row == 0) {
    bgView.position = UACellBackgroundViewPositionTop;
  } else if (row == 2 && indexPath.section == CONTACT_SECTION) {
    bgView.position = UACellBackgroundViewPositionBottom;
  } else if (row == 1 && indexPath.section == BUTTON_SECTION) {
    bgView.position = UACellBackgroundViewPositionBottom;
  } else {
    bgView.position = UACellBackgroundViewPositionMiddle;
  }

  SavingDictionary *settingsDict = SETTINGS_DICT;    
  
  switch (indexPath.section) {
    case CONTACT_SECTION:
      cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      if (indexPath.row == CONTACT_US_INDEX) {
        cell.textLabel.text = @"Contact Us";  
        break;
      } else if (indexPath.row == EMAIL_APP_INDEX) {
        cell.textLabel.text = @"Email Friend StopWatch+";  
        break;        
      } 
      cell.textLabel.text = @"Tweet About StopWatch+";  
      break;
    case SETTINGS_SECTION:
      if (indexPath.row == SKIN_INDEX) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Bowser Skin";  
        if ([[settingsDict objectForKey:BOWSER_PURCHASED]boolValue] != YES) {
          cell.accessoryType = UITableViewCellAccessoryNone;
          break;
        }
        if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
          cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
          cell.accessoryType = UITableViewCellAccessoryNone;        
        }
        break;
      } 
      if (indexPath.row == SOUND_INDEX) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Sound";  
        UISwitch *soundSwitch = [self addSwitchWithAction:@"toggleSound" cell:cell];
        SavingDictionary *sd = [[[SavingDictionary alloc]initWithClass:[SWPSettingsTableVC class]]autorelease];
        soundSwitch.on = [[sd objectForKey:@"SOUND_ENABLED"]boolValue];
        break;
      } 
    case BUTTON_SECTION:
      if (indexPath.row == START_SPLIT_INDEX) {
        [self setCell:cell forIndex:indexPath.row title:@"Start - Split"];
        break;
      } 
      [self setCell:cell forIndex:indexPath.row title:@"Start - Stop"];
      break;
    case PLEDGE_SECTION:
      cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      cell.textLabel.text = @"Pledge Wall";
      break;
    default:
      break;
  }
	return cell;
}


// the button section is likle a radio switch, and this methods toggles the checkmarks
- (void) setButtonStyleCheckmarks:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath {  
  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    for (int x=0;x<3;x++) {
      UITableViewCell *deselectCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:BUTTON_SECTION]];
      if (x != indexPath.row) {
        deselectCell.accessoryType = UITableViewCellAccessoryNone;
      }
    }
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == CONTACT_SECTION) {
    if (indexPath.row == EMAIL_FRIEND_SECTION) {
      [self emailFriend];  
      return;
    } else if (indexPath.row == CONTACT_US_INDEX) {
      [self contactUs];
      return;      
    } else if (indexPath.row == TWEET_US_INDEX) {
      [self tweetStopwatch];
      return;      
    }
    return;
  }
  
  SavingDictionary *settingsDict = SETTINGS_DICT;    
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  if (indexPath.section == BUTTON_SECTION) {
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
      return;
    }
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [settingsDict setObject:N(indexPath.row) forKey:BUTTON_MODE_KEY];
    [self setButtonStyleCheckmarks:cell indexPath:indexPath];
    [(SWPViewController*)self.presentingView resetTimer];
  }
  
  if (indexPath.section == SETTINGS_SECTION) {
    if (indexPath.row == SKIN_INDEX) {
      if ([[settingsDict objectForKey:BOWSER_KEY] isEqualToString:@"YES"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [settingsDict setObject:@"NO" forKey:BOWSER_KEY];
      } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [settingsDict setObject:@"YES" forKey:BOWSER_KEY];
      }
      [self switchSkins];
      return;
    }
  }

  if (indexPath.section == PLEDGE_SECTION) {
    [self showPledgeWall];
    return;
  }
}


- (CGFloat)tableView:(UITableView *)t heightForHeaderInSection:(NSInteger)s {
  return 30;
}


- (UIView *)tableView:(UITableView *)t viewForHeaderInSection:(NSInteger)section {
  float width = self.view.frame.size.width-10*4;
  UILabel *label = [[[UILabel alloc]initWithFrame:CGRectMake(10*2, 
                                                             0, 
                                                             width, 
                                                             30)]autorelease];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
  label.shadowColor = [UIColor whiteColor];
  UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 
                                                           0, 
                                                           self.view.frame.size.width, 
                                                           30)]autorelease];
  [view addSubview:label];
  
  switch (section) {
    case CONTACT_SECTION:
      label.text = @"About Us";
      break;
    case SETTINGS_SECTION:
      label.text = @"General";
      break;
    case BUTTON_SECTION:
      label.text = @"Timer Mode (Press/Hold to reset)";
      break;
    default:
      label.text = nil;
      break;
  }

  return view;
}


- (void) addHeader {}

@end
