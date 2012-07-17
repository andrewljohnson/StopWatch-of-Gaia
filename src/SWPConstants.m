//
//  SWPConstants.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPConstants.h"


@implementation SWPConstants

+ (NSString*) documentsDirectory {
  NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [documentPaths objectAtIndex:0];
}


+ (void) checkDirectory:(NSString*) filePath {
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
    if(![[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil])
      NSLog(@"Error: Create folder failed");
  } 
  
}


NSString* privateDocumentsDirectory() {
  static NSString* dir = nil;
  if (!dir) {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
    dir = [[[paths objectAtIndex:0] stringByAppendingString:@"/Private Documents"] retain];	
    [SWPConstants checkDirectory:dir];
    
  }
  return dir;
}


@end
