//
//  SWPTimeLabel.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

@interface SWPTimeLabel : UIView

@property(nonatomic, retain) UILabel *hoursLabel, *centisecondsLabel, *mainTimeLabel;
@property(nonatomic, assign) BOOL showCentiseconds, showGradient;
@property(nonatomic, assign) double timeInSeconds;

- (id)initWithFrame:(CGRect)frame fontSize:(int)fontSize;
- (void) setTime:(double)seconds;

@end
