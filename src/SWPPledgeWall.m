//
//  SWPPledgeWall.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/16/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPPledgeWall.h"
#import "SWPPledgeTable.h"
#import "SWPAppDelegate.h"
#import "SWPConstants.h"
#import "SWPStyle.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@implementation SWPPledgeWall
@synthesize pledges, pledgeCount;

- (void)dealloc {
  [pledges release];
	[super dealloc];
}


- (void) showPledgeTable {
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  [self.navigationController pushViewController:a.pledgeTable animated:YES];
}


// fetch up to PLEDGES_PER_CHUNK more pledges to show on the server 
- (void) loadMorePledges {
  PFQuery *query = [PFQuery queryWithClassName:@"Pledge"];
  [query orderByDescending:@"level"];
  [query addDescendingOrder:@"createdOnDevice"];
  query.limit = PLEDGES_PER_CHUNK;
  query.skip = [pledges count];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      if ([objects count] < PLEDGES_PER_CHUNK) {
        self.pledgeCount = NO_PLEDGES_TO_FETCH;
      } else {        
        self.pledgeCount = PLEDGES_TO_FETCH;
      }
      self.pledges = [self.pledges arrayByAddingObjectsFromArray:objects];
      [self.tableView reloadData];
    } else {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];  
}


// if we have never loaded pledges or we need to fresh, load pledges
- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if ([self.pledges count] == 0 || self.pledgeCount == FLAGGED_FOR_REFRESH) {    
    self.pledges = [NSMutableArray array];
    [self loadMorePledges];
    [[self.view viewWithTag:999]removeFromSuperview];
  }
}


- (void) addTableHeader {
  CGRect containerFrame = CGRectMake(0, 0, self.view.frame.size.width-20, 48);
  CGRect headerFrame = CGRectMake(10, 10, containerFrame.size.width-20, 38);
  CGRect titleLabelFrame = CGRectMake(10, 10, headerFrame.size.width-20, 18);
  UIView *container = [[[UIView alloc]initWithFrame:containerFrame]autorelease];
  container.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  UIView *headerView = [[[UIView alloc]initWithFrame:headerFrame]autorelease];
  headerView.layer.cornerRadius = 4;
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  headerView.layer.borderWidth = 1;
  headerView.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]CGColor];
  headerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.6];
  
  UILabel *titleLabel = [[[UILabel alloc]initWithFrame:titleLabelFrame]autorelease];
  titleLabel.text = @"Messages from Stopwatch+ Users";
  titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  titleLabel.shadowColor = [UIColor whiteColor];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
  
  [container addSubview:headerView];
  [headerView addSubview:titleLabel];
  self.tableView.tableHeaderView = container;
}


- (void) addLoadingSpinner {
  UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]autorelease];
  spinner.frame = CGRectMake(self.view.frame.size.width/2-64/2, 
                             self.view.frame.size.height/3,
                             64,
                             64);
  spinner.tag = 999;
  spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  [spinner startAnimating];
  [self.view addSubview:spinner];
}


- (void) viewDidLoad {
  [super viewDidLoad];
  self.title = @"Pledges";
  [self addLoadingSpinner];
  [self addTableHeader];
  
  self.pledges = [NSMutableArray array];
  pledgeCount = 0;
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Pledge!" style:UIBarButtonItemStyleDone target:self action:@selector(showPledgeTable)]autorelease];
}


- (UIFont*) fontForPledge:(NSDictionary*)pledge {
  if ([[pledge objectForKey:@"level"] isEqual:N(1)]) {
    return [UIFont fontWithName:@"Helvetica-Bold" size:16];
  } else if ([[pledge objectForKey:@"level"] isEqual:N(2)]) {
    return [UIFont fontWithName:@"Helvetica-Bold" size:20];    
  } else {
    return [UIFont fontWithName:@"Helvetica" size:16];
  }
}


#pragma mark - Table view methods

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellID = @"Cell";
  UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID] autorelease];
  }
  
  if (indexPath.row == [pledges count]) {
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = @"Load more messages...";
    cell.detailTextLabel.text = nil;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    return cell;
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;

  NSDictionary *pledge = [pledges objectAtIndex:indexPath.row];
  cell.textLabel.numberOfLines = 11;
  cell.textLabel.backgroundColor = [UIColor clearColor];
  cell.textLabel.text = [pledge objectForKey:@"message"];
  cell.textLabel.font = [self fontForPledge:pledge];
  cell.detailTextLabel.backgroundColor = [UIColor clearColor];
  cell.detailTextLabel.text = [SWPStyle formatDate:[pledge objectForKey:@"createdOnDevice"]];
  if ([[pledge objectForKey:@"level"]intValue] == 0) {
    cell.backgroundColor = BRONZE_COLOR;    
  } else if ([[pledge objectForKey:@"level"]intValue] == 1) {
    cell.backgroundColor = SILVER_COLOR;    
  } else {
    cell.backgroundColor = GOLD_COLOR;      
  }
  return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == [pledges count]) {
    [self loadMorePledges];
  }
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
  if (indexPath.row == [pledges count]) {
    return 60;
  }
  CGSize maximumLabelSize = CGSizeMake(aTableView.frame.size.width,1000);
  NSDictionary *pledge = [pledges objectAtIndex:indexPath.row];

	CGSize expectedLabelSize = [[pledge objectForKey:@"message"] sizeWithFont:[self fontForPledge:pledge] 
                                        constrainedToSize:maximumLabelSize 
                                            lineBreakMode:UILineBreakModeTailTruncation]; 
	
  return expectedLabelSize.height+60;  
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([pledges count]==0) return 0;
  else if (pledgeCount > 0) return [pledges count] + 1;
  return [pledges count];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {  
  return YES;
} 

@end
