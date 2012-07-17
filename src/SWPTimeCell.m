//
//  SWPTimeCell.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPTimeCell.h"
#import "SWPTimeLabel.h"
#import "SWPStyle.h"


@implementation SWPTimeCell
@synthesize timeLabel, totalLabel, dateLabel;

- (void) dealloc {
  self.timeLabel = nil;
  self.totalLabel = nil;
  self.dateLabel = nil;
  [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
    self.dateLabel = [[[UILabel alloc]init]autorelease];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    dateLabel.textAlignment = UITextAlignmentLeft;
    [self.contentView addSubview:dateLabel];
    self.timeLabel = [[[SWPTimeLabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width/3, self.contentView.frame.size.height) fontSize:30]autorelease];
    [self.contentView addSubview:timeLabel];
    self.totalLabel = [[[SWPTimeLabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width/3, self.contentView.frame.size.height) fontSize:30]autorelease];
    [self.contentView addSubview:totalLabel];

  }
  return self;
}


- (void) layoutSubviews {
  [super layoutSubviews];
  CGRect fr = CGRectMake(5, 0, self.contentView.frame.size.width/3+20, self.contentView.frame.size.height);
  self.dateLabel.frame = fr;
  fr.origin.x += self.contentView.frame.size.width/3+5;
  fr.size.width -= 30;
  self.timeLabel.frame = fr;
  fr.origin.x += self.contentView.frame.size.width/3-5;
  self.totalLabel.frame = fr;
}


- (void) setTimeForDict:(NSDictionary*)timeDict totalTime:(NSTimeInterval)totalTime {
  self.dateLabel.text = [SWPStyle formatDate:[timeDict objectForKey:@"timeStopped"]];
  [self.timeLabel setTime:[[timeDict objectForKey:@"seconds"]floatValue]];
  [self.totalLabel setTime:totalTime];
}

@end
