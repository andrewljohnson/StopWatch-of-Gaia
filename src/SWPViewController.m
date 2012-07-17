//
//  SWPViewController.m
//  StopWatch+
//
//  Created by Andrew JOhnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPViewController.h"
#import "SWPTimeLabel.h"
#import "SWPTimeTableVC.h"
#import "SavingDictionary.h"
#import "SWPConstants.h"
#import "SWPSettingsTableVC.h"
#import "SWPCountdownPicker.h"
#import "SWPAppDelegate.h"
#import "SWPStyle.h"
#import <QuartzCore/QuartzCore.h>

@implementation SWPViewController
@synthesize timerButton, timeLabel, timer, needsToReset, times, buttonTimer, cancelUpAction, startTime, splits, endTime, timesButton, buttonBacks;

@synthesize soundFileURLRefStart, soundFileURLRefStop, soundFileURLRefReset, soundFileURLRefSilent;
@synthesize soundFileObject;

CFBundleRef mainBundle;

- (void) dealloc {
  [super dealloc];
  [self.timer invalidate];
  self.timer = nil;
  [self.buttonTimer invalidate];
  self.buttonTimer = nil;
  self.times = nil;
  self.startTime = nil;
  self.splits = nil;
  self.endTime = nil;
  self.buttonBacks = nil;
}


- (void)viewDidUnload {
  [super viewDidUnload];
  self.timerButton = nil;
  self.timesButton = nil;
  self.timeLabel = nil;
}


- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self updateTime];
}


- (void) playSound:(CFURLRef)soundRef {
  SavingDictionary *sd = [[[SavingDictionary alloc]initWithClass:[SWPSettingsTableVC class]]autorelease];  
  if(![[sd objectForKey:@"SOUND_ENABLED"]isEqual:N(YES)]) {
    return;
  }
  AudioServicesCreateSystemSoundID (soundRef, &soundFileObject);
  AudioServicesPlaySystemSound (self.soundFileObject);  
}


// update the time label
- (void) updateTime {
  
  if (isCountdown) {
    [self.timeLabel setTime:countdownSeconds+[startTime timeIntervalSinceDate:[NSDate date]]];
    
    if (countdownSeconds+[startTime timeIntervalSinceDate:[NSDate date]] <= 0) {
      [self clearTime];
    }
    return;
  }
  
  if (!self.splits) {
    if (endTime) {
      [self.timeLabel setTime:-[startTime timeIntervalSinceDate:endTime]];
      return;
    }
    [self.timeLabel setTime:-[startTime timeIntervalSinceDate:[NSDate date]]];
    return;
  }
  
  if ([self.splits count]== 0) {
    [self.timeLabel setTime:0];
    return;
    
  }
  
  if ([self.splits count]== 1) {
    [self.timeLabel setTime:-[[self.splits objectAtIndex:0] timeIntervalSinceNow]];
    return;
  }
  
  NSTimeInterval totalTime = 0;
  int index = 0;
  for (NSDate *date in self.splits) {
    index++;
    if (index %2 != 0) {
      totalTime -= [date timeIntervalSinceDate:[self.splits objectAtIndex:index]];
    }
    if (index == [self.splits count]-1) {
      break;
    }
  }
  NSDate *lastDate = [self.splits objectAtIndex:[self.splits count]-1];
  if ([self.splits count] % 2 != 0) {
    totalTime -= [lastDate timeIntervalSinceDate:[NSDate date]];
  }
  [self.timeLabel setTime:totalTime];
  
}

- (void) showSettingsScreen {
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  SWPSettingsTableVC *settingsTable = a.settingsScreen;
  settingsTable.presentingView = self;
  UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:settingsTable]autorelease];
  [SWPStyle setStyleForNavBar:nav.navigationBar];
  [self presentModalViewController:nav animated:YES];
}


- (void) showPledgeWall {
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  SWPSettingsTableVC *settingsTable = a.settingsScreen;
  settingsTable.presentingView = self;
  UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:settingsTable]autorelease];
  [SWPStyle setStyleForNavBar:nav.navigationBar];
  [self presentModalViewController:nav animated:NO];
  [settingsTable showPledgeWall];
}


- (void) saveTime {
  NSDictionary *timeDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"timeStopped", [NSNumber numberWithFloat:-[startTime timeIntervalSinceNow]], @"seconds", nil];
  NSMutableArray *timeList = [times objectForKey:@"timeList"];
  [timeList addObject:timeDict];
  [times setObject:timeList forKey:@"timeList"];
}


- (void) resetTimer {
  [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
  if (!self.timer) {
    return;
  }
  [self saveTime];
  [self.timer invalidate];
  self.timer = nil;
  [self.timeLabel setTime:0];
  needsToReset = NO;
}


- (BOOL) startTimer { 
  [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
  if (!self.timer) {
    self.startTime = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(.01)
                                                  target:self
                                                selector:@selector(updateTime)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer
                                 forMode:NSRunLoopCommonModes];
    return YES;
  }
  return NO;
}


- (void) stopTimer {
  [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
  [self playSound:soundFileURLRefStop];
  [self.timer invalidate];
  self.timer = nil;
}


- (void) doStartSplitCycle {
  [self startTimer];
  [self saveTime];
  self.timesButton.alpha = 0;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:.25];
  self.timesButton.alpha = 1;  
  [UIView commitAnimations];
  [self playSound:soundFileURLRefStart];
}


- (void) doStartStopCycle {
  if (!self.splits) {
    self.splits = [NSMutableArray array];
  }
  [self.splits addObject:[NSDate date]];
  if (!self.timer) {
    [self playSound:soundFileURLRefStart];
    [self startTimer];
    return;
  }
  [self stopTimer];
  [self saveTime];
}


- (void) doCountdownCycle {
  if (!hasStartedCountdown) {
    self.startTime = [NSDate date];
    hasStartedCountdown = YES;
  }
  if (!self.timer) {
    countdownSeconds = self.timeLabel.timeInSeconds;
    [self playSound:soundFileURLRefStart];
    [self startTimer];
    return;
  }
  [self stopTimer];
}


// MODE 2 - start, split, ...
// MODE 2 - start, stop, ...
- (void) timerButtonPressed {
  // if they were holding down to reset, skip the normal action
  if (cancelUpAction) {
    cancelUpAction = NO;
    return;
  }
  
  [self.buttonTimer invalidate];
  self.buttonTimer = nil;
  
  if (isCountdown) {
    [self doCountdownCycle];
    return;
  }
  
  if ([[SETTINGS_DICT objectForKey:BUTTON_MODE_KEY]intValue] == START_SPLIT_INDEX) {
    [self doStartSplitCycle];
    return;
  }
  
  [self doStartStopCycle];
}


// show the list of times
- (void)showTimes {  
  SWPTimeTableVC *timeTable = [[[SWPTimeTableVC alloc]initWithStyle:UITableViewStyleGrouped]autorelease];
  timeTable.times = times;
  timeTable.presentingView = self;
  UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:timeTable]autorelease];
  [SWPStyle setStyleForNavBar:nav.navigationBar];
  [self presentModalViewController:nav animated:YES];
}


- (void) showCountdownPicker {
  if (isCountdown) {
    [self clearTime];
    cancelUpAction = NO;
    return;
  }
  SWPCountdownPicker *timeTable = [[[SWPCountdownPicker alloc]init]autorelease];
  UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:timeTable]autorelease];  
  [SWPStyle setStyleForNavBar:nav.navigationBar];
  [self presentModalViewController:nav animated:YES];
}


- (void) clearTime {
  isCountdown = NO;
  [self playSound:soundFileURLRefReset];
  cancelUpAction = YES;
  [self.timer invalidate];
  self.timer = nil;
  self.startTime = nil;
  self.endTime = nil;
  [self.timeLabel setTime:0];
  needsToReset = NO;
  [self.buttonTimer invalidate];
  self.buttonTimer = nil;
  self.splits = nil;
  [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
}


// reset the clock if they press and hold
- (void) timerButtonHeld {
  [self.buttonTimer invalidate];
  self.buttonTimer = nil;
  self.buttonTimer = [NSTimer scheduledTimerWithTimeInterval:(.5)
                                                      target:self
                                                    selector:@selector(clearTime)
                                                    userInfo:nil
                                                     repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:buttonTimer
                               forMode:NSRunLoopCommonModes];
}


- (void) initSound {
  mainBundle = CFBundleGetMainBundle ();
  soundFileURLRefSilent  = CFBundleCopyResourceURL (mainBundle,CFSTR("noSound"),CFSTR("wav"),NULL);
  AudioServicesCreateSystemSoundID (soundFileURLRefSilent, &soundFileObject);
  AudioServicesPlaySystemSound (self.soundFileObject);  soundFileURLRefStart  = CFBundleCopyResourceURL (mainBundle,CFSTR("request"),CFSTR("wav"),NULL);
  soundFileURLRefStop  = CFBundleCopyResourceURL (mainBundle,CFSTR("success"),CFSTR("wav"),NULL);
  soundFileURLRefReset  = CFBundleCopyResourceURL (mainBundle,CFSTR("chime3"),CFSTR("wav"),NULL);
  [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}


- (void) countdown:(double)seconds {
  [self dismissModalViewControllerAnimated:NO];
  countdownSeconds = seconds;
  [self clearTime];
  isCountdown = YES;
  cancelUpAction = NO;
  [self.timeLabel setTime:seconds];
  hasStartedCountdown = NO;
}


- (UIButton*) addButtonWithFrame:(CGRect)bgFrame imageName:(NSString*)imageName action:(SEL)action {
  UIView *v = [[[UIView alloc]initWithFrame:bgFrame]autorelease];
  v.backgroundColor = [SWPStyle transparentlineColor];
  v.layer.cornerRadius = 30;
  v.layer.borderWidth = 2;
  v.layer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:.3]CGColor];
  [self.view addSubview:v];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
  button.frame = CGRectMake(14, 14, 32, 32);
  [button addTarget:self 
             action:action 
   forControlEvents:UIControlEventTouchDown];
  [v addSubview:button];
  [buttonBacks addObject:v];
  return button;
}


// add the buttons and label to the view
- (void)viewDidLoad {
  [super viewDidLoad];
  if (!self.buttonBacks) {
    self.buttonBacks = [NSMutableArray array];
    isCountdown = NO;
    needsToReset = NO;
    cancelUpAction = NO;
    countdownSeconds = 0;  
    [self initSound];    
  }
  
  UITableView *bg = [[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped]autorelease];
  bg.userInteractionEnabled = NO;
  bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:bg];
  
  // the label that ticks down the time
  CGRect timerLabelFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  int fontSize = 170;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    fontSize = 360;
  }
  self.timeLabel = [[[SWPTimeLabel alloc]initWithFrame:timerLabelFrame fontSize:fontSize]autorelease];
  timeLabel.showGradient = YES;
  self.timeLabel.userInteractionEnabled = NO;
  self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self updateTime];
  [self.view addSubview:timeLabel];
  
  
  self.times = [[[SavingDictionary alloc]initWithPath:[[SWPConstants documentsDirectory] stringByAppendingPathComponent:@"times.json"]]autorelease];
  if (![times objectForKey:@"timeList"]) {
    [times setObject:[NSMutableArray array] forKey:@"timeList"];    
  }
  
  CGRect bgFrame = CGRectMake(10, 10, 60, 60);
  self.timesButton = [self addButtonWithFrame:bgFrame 
                                    imageName:@"list.png" 
                                       action:@selector(showTimes)];
  bgFrame.origin.x = self.view.frame.size.width/2-60/2;
  UIButton * countdownButton = [self addButtonWithFrame:bgFrame 
                                              imageName:@"hourglass.png" 
                                                 action:@selector(showCountdownPicker)];
  bgFrame.origin.x = self.view.frame.size.width-70;
  countdownButton.superview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  UIButton * settingsButton = [self addButtonWithFrame:bgFrame 
                                             imageName:@"wrench-icon-large.png" 
                                                action:@selector(showSettingsScreen)];
  settingsButton.superview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  [self updateTime];
  return YES;
}


- (BOOL) touchedTopButtons:(UITouch*)touch event:(UIEvent*)event {
  for (UIView * view in buttonBacks) {    
    if ([view pointInside:[self.view convertPoint:[touch locationInView:self.view] 
                                           toView:view] 
                withEvent:event]) {
      return YES;
    }
  }
  return NO;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![self touchedTopButtons:[touches anyObject] event:event]) {
    [self timerButtonHeld];    
  }
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![self touchedTopButtons:[touches anyObject] event:event]) {
    [self timerButtonPressed];
  }  
}


- (void) refreshColors {
  self.view.backgroundColor = [SWPStyle bgColor];
  self.timeLabel.mainTimeLabel.textColor = [SWPStyle textColor];
  for (UIView *b in buttonBacks) {
    b.backgroundColor = [SWPStyle transparentlineColor];
  }
  [self.timeLabel setNeedsDisplay];
}


- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshColors];
}

@end
