//
//  RoundedGradientCellBackground.h
//  TrailTracker
//
//  Created by Andrew Johnson on 4/4/10.
//  Copyright 2010 . All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum  {
  UACellBackgroundViewPositionSingle = 0,
  UACellBackgroundViewPositionTop, 
  UACellBackgroundViewPositionBottom,
  UACellBackgroundViewPositionMiddle
} UACellBackgroundViewPosition;

@interface RoundedGradientCellBackground : UIView {
  UACellBackgroundViewPosition position;
}

@property(nonatomic) UACellBackgroundViewPosition position;

@end
