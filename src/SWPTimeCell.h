//
//  SWPTimeCell.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

@class SWPTimeLabel;

@interface SWPTimeCell : UITableViewCell

@property(nonatomic, retain) UILabel *dateLabel;
@property(nonatomic, retain) SWPTimeLabel *timeLabel, *totalLabel;

- (void) setTimeForDict:(NSDictionary*)timeDict totalTime:(NSTimeInterval)totalTime;

@end
