//
//  SWPViewController.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
@class SWPTimeLabel, SavingDictionary;


@interface SWPViewController : UIViewController {
  CFURLRef soundFileURLRefStart, soundFileURLRefStop, soundFileURLRefReset;
  SystemSoundID soundFileObject;
  BOOL isCountdown, hasStartedCountdown;
  double countdownSeconds;
}

@property (readwrite) CFURLRef soundFileURLRefStart, soundFileURLRefStop, soundFileURLRefReset, soundFileURLRefSilent;
@property (readonly) SystemSoundID soundFileObject;
@property(nonatomic,retain) SWPTimeLabel *timeLabel;
@property(nonatomic,retain) UIButton *timerButton, *timesButton;
@property(nonatomic,retain) NSTimer *timer, *buttonTimer;
@property(nonatomic,assign) BOOL needsToReset, cancelUpAction;
@property(nonatomic,retain) SavingDictionary *times;
@property(nonatomic,retain) NSDate *startTime, *endTime;
@property(nonatomic,retain) NSMutableArray *splits, *buttonBacks;

- (void) resetTimer;
- (void) showSettingsScreen;
- (void) countdown:(double)seconds;
- (void) showPledgeWall;

@end
