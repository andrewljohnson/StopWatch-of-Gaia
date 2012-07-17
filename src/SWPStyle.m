//
//  SWPStyle.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/30/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPStyle.h"
#import "SWPConstants.h"
#import "SavingDictionary.h"


@implementation SWPStyle

+ (UIColor*) textColor {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    return [UIColor yellowColor];
  }
  return [UIColor greenColor];
}


+ (void) setStyleForNavBar:(UINavigationBar*)bar {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    bar.tintColor = [UIColor redColor];
    return;
  }
  bar.tintColor = nil;
  bar.barStyle = UIBarStyleBlack;
}


+ (UIColor*) bgColor {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    return [UIColor redColor];
  }
  return [UIColor blackColor];
}


+ (UIColor*) lineColor {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    return [UIColor redColor];
  }
  return [UIColor greenColor];
}


+ (UIColor*) transparentlineColor {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    return [UIColor colorWithRed:.4 green:0 blue:0 alpha:.2];
  }
  return [UIColor colorWithRed:0 green:.4 blue:0 alpha:.2];
}


+ (UIFont*) fontOfSize:(int)fontSize {
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  if ([[settingsDict objectForKey:BOWSER_KEY]boolValue] == YES) {
    return [UIFont fontWithName:@"Helvetica Bold" size:fontSize];
  }
  return HBOLD(24);
}


+ (NSString*) formatDate:(NSDate*) date {
	static NSDateFormatter *dateFormatter = nil;
  static NSTimeInterval gmtInterval;
  if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, hh:mm a"];
    gmtInterval = -(NSTimeInterval) [[NSTimeZone systemTimeZone] secondsFromGMT];
	}
  
  NSString *dateString = [dateFormatter stringFromDate:date];
	return dateString;
}	

@end
