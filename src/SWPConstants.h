//
//  SWPConstants.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#define N(N$)  [NSNumber numberWithInt: (N$)]
#define F(N$)  [NSNumber numberWithFloat: (N$)]
#define HBOLD(N$)  [UIFont fontWithName:@"digital-7" size:N$];

#define SETTINGS_DICT [[[SavingDictionary alloc]initWithPath:[[SWPConstants documentsDirectory] stringByAppendingPathComponent:@"settings.txt"]]autorelease]

#define BOWSER_PURCHASED @"bowserPurchased"
#define BOWSER_KEY @"useBowserSkin"


@interface SWPConstants : NSObject

+ (NSString*) documentsDirectory;
NSString* privateDocumentsDirectory();


@end
