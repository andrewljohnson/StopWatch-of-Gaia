//
//  RoundedGradientCellBackground.m
//  TrailTracker
//
//  Created by Andrew Johnson on 4/4/10.
//  Copyright 2010 . All rights reserved.
//

#define kDefaultMargin           10

#import "RoundedGradientCellBackground.h"
#import "SWPStyle.h"


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);

@implementation RoundedGradientCellBackground
@synthesize position;

#define PADDING 10

- (BOOL) isOpaque {
  return NO;
}

- (void)drawRect:(CGRect)aRect {
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

  CGContextSetStrokeColorWithColor(c, [[SWPStyle textColor] CGColor]);
  CGContextSetLineWidth(c, lineWidth);
  CGContextSetAllowsAntialiasing(c, YES);
  CGContextSetShouldAntialias(c, YES);
  
  if (position == UACellBackgroundViewPositionTop) {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, maxy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, kDefaultMargin);
    CGPathAddLineToPoint(path, NULL, maxx, maxy);
    CGPathAddLineToPoint(path, NULL, minx, maxy);
    CGPathCloseSubpath(path);
    
    // Fill and stroke the path
    CGContextSaveGState(c);
    CGContextAddPath(c, path);
    CGContextClip(c);
    
    
    CGFloat components[8] = { 60/255.0, 60/255.0, 60/255.0, 1, 40/255.0, 40/255.0, 40/255.0, 1};
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 2);
    CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
    
    CGContextAddPath(c, path);
    CGContextStrokePath(c);
    CGPathRelease(path);
    CGContextRestoreGState(c);
    
  } else if (position == UACellBackgroundViewPositionBottom) {
    maxy -= 1;
    CGFloat components[8] = {40/255.0, 40/255.0, 40/255.0, 1, 0/255.0, 0/255.0, 0/255.0, 1};
  
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, miny);
    CGPathAddArcToPoint(path, NULL, minx, maxy, midx, maxy, kDefaultMargin);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx, miny, kDefaultMargin);
    CGPathAddLineToPoint(path, NULL, maxx, miny);
    CGPathAddLineToPoint(path, NULL, minx, miny);
    CGPathCloseSubpath(path);
    
    // Fill and stroke the path
    CGContextSaveGState(c);
    CGContextAddPath(c, path);
    CGContextClip(c);
    
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 2);
    CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
    
    CGContextAddPath(c, path);
    CGContextStrokePath(c);
    CGPathRelease(path);
    CGContextRestoreGState(c);
    
    
  } else if (position == UACellBackgroundViewPositionMiddle) {
    CGFloat components[8] = {40/255.0, 40/255.0, 40/255.0, 1, 40/255.0, 40/255.0, 40/255.0, 1};

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, miny);
    CGPathAddLineToPoint(path, NULL, maxx, miny);
    CGPathAddLineToPoint(path, NULL, maxx, maxy);
    CGPathAddLineToPoint(path, NULL, minx, maxy);
    CGPathAddLineToPoint(path, NULL, minx, miny);
    CGPathCloseSubpath(path);
    
    // Fill and stroke the path
    CGContextSaveGState(c);
    CGContextAddPath(c, path);
    CGContextClip(c);
    
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 2);
    CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
    
    CGContextAddPath(c, path);
    CGContextStrokePath(c);
    CGPathRelease(path);
    CGContextRestoreGState(c);
    
  } else if (position == UACellBackgroundViewPositionSingle) {
    maxy -= 1;
    
    CGFloat components[8] = {60/255.0, 60/255.0, 60/255.0, 1, 0/255.0, 0/255.0, 0/255.0, 1};

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
  }
  
  CGColorSpaceRelease(myColorspace);
  CGGradientRelease(myGradient);
  
  // if you need to draw the chevron
  if (self.tag == 999) {
    float middleX, middleY, bottomY, topX, topY;
    float chevronWidth = PADDING;
    float chevronHeight = PADDING;
    topX = aRect.size.width - PADDING - chevronWidth;
    topY = aRect.size.height/2 - chevronHeight/2;
    middleX = aRect.size.width - PADDING - chevronWidth/2;
    middleY = aRect.size.height/2;
    bottomY = aRect.size.height/2 + chevronHeight/2;
    UIColor *color = [SWPStyle textColor];
    float *col = (float*)CGColorGetComponents([color CGColor]);
    CGContextSetRGBStrokeColor(c, col[0], col[1], col[2], 1);
    CGContextSetLineJoin (c,kCGLineJoinRound);     
    CGContextSetLineWidth(c, 3);
    
    // Draw a connected sequence of line segments
    CGPoint addLines[] =
    {
      CGPointMake(topX, topY),
      CGPointMake(middleX, middleY),
      CGPointMake(topX, bottomY),
    };
    CGContextAddLines(c, addLines, sizeof(addLines)/sizeof(addLines[0]));
    CGContextStrokePath(c);
  }    
  
  return;
}


- (void)dealloc {
  [super dealloc];
}


- (void)setPosition:(UACellBackgroundViewPosition)newPosition {
  if (position != newPosition) {
    position = newPosition;
    [self setNeedsDisplay];
  }
}

@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight) {
  float fw, fh;
  
  if (ovalWidth == 0 || ovalHeight == 0) {// 1
    CGContextAddRect(context, rect);
    return;
  }
  
  CGContextSaveGState(context);// 2
  
  CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
                         CGRectGetMinY(rect));
  CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
  fw = CGRectGetWidth (rect) / ovalWidth;// 5
  fh = CGRectGetHeight (rect) / ovalHeight;// 6
  
  CGContextMoveToPoint(context, fw, fh/2); // 7
  CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
  CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
  CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
  CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
  CGContextClosePath(context);// 12
  
  CGContextRestoreGState(context);// 13
}