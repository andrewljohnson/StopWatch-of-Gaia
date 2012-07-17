//
//  SWPTimeLabel.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPTimeLabel.h"
#import "SWPAppDelegate.h"
#import "SWPViewController.h"
#import "SWPStyle.h"
#import "SWPConstants.h"


@implementation SWPTimeLabel
@synthesize hoursLabel, centisecondsLabel, mainTimeLabel;
@synthesize  showCentiseconds, showGradient, timeInSeconds;

- (void) dealloc {
  self.hoursLabel = nil;
  self.centisecondsLabel = nil;
  self.mainTimeLabel = nil;
  [super dealloc];
}


- (NSString*)timeString:(NSTimeInterval)timeVar {	
	int hours = ((int)timeVar/3600) % 3600;
	int minutes = ((int)timeVar/60) % 60;
	int seconds = (int)timeVar % 60;
  int hundredths = (timeVar - (int)timeVar)*100;
  
  if (hours > 0) {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];    
  }
  if (minutes > 0) {
    return [NSString stringWithFormat:@"%02d:%02d.%02d", minutes, seconds, hundredths];    
  }
  return [NSString stringWithFormat:@"%02d.%02d", seconds, hundredths];    
} 


- (void) adjustFrameForLandscape:(CGRect)fr {
  UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice]orientation];
  if (interfaceOrientation == UIInterfaceOrientationPortrait
      || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
    fr.origin.y = 0;
  } else {
    fr.origin.y = 30;
  }
  self.mainTimeLabel.frame = fr;
}


- (void) setTime:(double)seconds {
  self.timeInSeconds = seconds;
  self.mainTimeLabel.text = [self timeString:seconds]; 
  CGRect fr = self.bounds;
  fr.origin.x +=10;
  fr.size.width -= 20;
  if (showGradient) {
    fr.size.height -= 50;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      fr.size.height -= 70;
    }
  }
  self.mainTimeLabel.frame = fr;

  // hack to adjust the vertical alignment of the main time label a bit
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  if ([self isEqual:[a.viewController timeLabel]]) {
    [self adjustFrameForLandscape:fr];
    return;
  }
}


- (UILabel*)defaultLabel:(CGRect)frame fontSize:(int)fontSize {
  UILabel *lbl = [[[UILabel alloc]initWithFrame:frame]autorelease];
  lbl.font = HBOLD(fontSize);
  lbl.backgroundColor = [UIColor clearColor];  
  lbl.textColor = [SWPStyle textColor];
  lbl.textAlignment = UITextAlignmentCenter;
  lbl.shadowColor = [UIColor whiteColor];
  lbl.shadowOffset = CGSizeMake(0, -1.0);
  lbl.adjustsFontSizeToFitWidth = YES;
  return lbl;
}


- (id)initWithFrame:(CGRect)frame fontSize:(int)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
      self.showGradient = NO;
      self.mainTimeLabel = [self defaultLabel:CGRectZero fontSize:fontSize];   
      self.backgroundColor = [UIColor clearColor];
      [self addSubview:mainTimeLabel];
      self.clipsToBounds = YES;
      [self setTime:0];
    }
    return self;
}


- (void)drawRect:(CGRect)aRect {
  [super drawRect:aRect];
  if (!showGradient) {
    return;
  }
  CGContextRef c = UIGraphicsGetCurrentContext();
  int lineWidth = 1;  
  CGRect rect = [self bounds];
  rect.size.width -= lineWidth;
  rect.size.height -= lineWidth;
  rect.origin.x += lineWidth / 2.0;
  rect.origin.y += lineWidth / 2.0;
  
  CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
  CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
  maxy += 1;
  
  CGFloat locations[2] = { 0.0, 1.0 };
  
  CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef myGradient = nil;  
  CGContextSetStrokeColorWithColor(c, [[SWPStyle lineColor]CGColor]);
  CGContextSetLineWidth(c, lineWidth);
  CGContextSetAllowsAntialiasing(c, YES);
  CGContextSetShouldAntialias(c, YES);
  
  maxy -= 1;
  int kDefaultMargin = 0;
  CGFloat components[8] = {0, 0, 0, .65, 0, 0, 0, .95};
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, minx, midy);
  CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
  CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, kDefaultMargin);
  CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, kDefaultMargin);
  CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, kDefaultMargin);
  CGPathCloseSubpath(path);
  
  // Fill and stroke the path
  CGContextSaveGState(c);
  CGContextAddPath(c, path);
  CGContextClip(c);
  

  myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 2);
  CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
  
  CGContextAddPath(c, path);
  CGPathRelease(path);
  CGContextStrokePath(c);
  CGContextRestoreGState(c);	
  
  CGColorSpaceRelease(myColorspace);
  CGGradientRelease(myGradient);
}


@end
