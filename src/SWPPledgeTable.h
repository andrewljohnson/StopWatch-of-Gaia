//
//  SWPPledgeTable.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/16/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#define BRONZE_COLOR  [UIColor colorWithRed:205/255.0 green:127/255.0 blue:50/255.0 alpha:.3]
#define SILVER_COLOR [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:.3]
#define GOLD_COLOR  [UIColor colorWithRed:255/255.0 green:215/255.0 blue:0/255.0 alpha:.3]
#define DARK_GOLD_COLOR  [UIColor colorWithRed:204/255.0 green:204/255.0 blue:0/255.0 alpha:1]

@interface SWPPledgeTable : UITableViewController { }

@property(nonatomic, retain) NSArray *pledgeProducts;
@property(nonatomic, retain) UITextField *pledgeField;
@property(nonatomic, assign) int buyRow;

- (void) addPledge;

@end
