//
//  SWPPledgeWall.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/16/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#define FLAGGED_FOR_REFRESH -1
#define PLEDGES_PER_CHUNK 1000
#define NO_PLEDGES_TO_FETCH 0
#define PLEDGES_TO_FETCH 1

@interface SWPPledgeWall : UITableViewController {
  
}

@property (nonatomic, retain) NSArray *pledges;
@property (nonatomic, assign) int pledgeCount;

@end
