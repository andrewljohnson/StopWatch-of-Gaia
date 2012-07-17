//
//  SWPStyle.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/30/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

@interface SWPStyle : NSObject

+ (UIColor*) textColor;  
+ (UIColor*) bgColor;
+ (UIColor*) lineColor;
+ (UIColor*) transparentlineColor;
+ (void) setStyleForNavBar:(UINavigationBar*)bar;
+ (NSString*) formatDate:(NSDate*) date;

@end
