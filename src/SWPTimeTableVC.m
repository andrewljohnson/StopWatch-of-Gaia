//
//  SWPTimeTableVC.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 4/7/12.
//  Copyright (c) 2012 TrailBehind, Inc.  All rights reserved.
//

#import "SWPTimeTableVC.h"
#import "SWPTimeCell.h"
#import "SWPConstants.h"
#import "RoundedGradientCellBackground.h"
#import "SWPStyle.h"


@implementation SWPTimeTableVC
@synthesize times, presentingView, cumulativeTotals;


- (void)dealloc {
	[cumulativeTotals release];
	[times release];
  [self.presentingView release];
	[super dealloc];
}


- (void) exportTimesAsCSV {
  NSString *timeString = @"";
  for (int x=0; x<[[times objectForKey:@"timeList"]count];x++) {
    NSDictionary *timeDict = [[times objectForKey:@"timeList"]objectAtIndex:x];
    NSString *timeLine = [NSString stringWithFormat:@"%@,%@\n",[timeDict objectForKey:@"timeStopped"], [timeDict objectForKey:@"seconds"]]; 
    timeString = [timeString stringByAppendingString:timeLine];
  }
  MFMailComposeViewController* controller = [[[MFMailComposeViewController alloc] init]autorelease];
	controller.mailComposeDelegate = self;
  [controller addAttachmentData:[timeString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"times.csv"];
	[controller setSubject:@"Time List from StopWatch+"];
   NSString *appStoreURL = @"http://itunes.apple.com/us/app/gaia-gps/id329127297?mt=8";
  NSString *body = [NSString stringWithFormat:@"These are some times recorded on StopWatch+.<br><br>Check out StopWatch+. It's a great app for your iPhone that records time in an amazing way. <a href=%@>You can download it from iTunes</a>.", appStoreURL];
	[controller setMessageBody:body isHTML:YES]; 
	[self presentModalViewController:controller animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
  if (result == MFMailComposeResultSent) {
  	
  }
  [self dismissModalViewControllerAnimated:YES];
}


// when the user swipes, go back to the stop watch
- (void) showStopwatch {
  [self.presentingView dismissModalViewControllerAnimated:YES];
}


- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{    
	if (buttonIndex == 0) {
    return;
  }
  [times setObject:[NSMutableArray array] forKey:@"timeList"];
  [self.tableView reloadData];
}  


- (void) resetTimes {
  UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Delete times?" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil]autorelease];
  [av show];
  
}


- (UILabel*) getHeaderLabelWithIndex:(int)index {
  float width = self.tableView.frame.size.width/3;
  UILabel *label = [[[UILabel alloc]initWithFrame:CGRectMake(index*width+5, 
                                                             0, 
                                                             width, 
                                                             22)]autorelease];
  label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
  label.textColor = [UIColor blackColor];
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = UITextAlignmentCenter;
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  label.shadowColor = [UIColor whiteColor];
  return label;
  
}


- (void) addHeader {
  UILabel *lbl = [self getHeaderLabelWithIndex:0]; 
  lbl.text = @"Date";
  UILabel *lbl1 = [self getHeaderLabelWithIndex:1]; 
  lbl1.text = @"Time";
  UILabel *lbl2 = [self getHeaderLabelWithIndex:2]; 
  lbl2.text = @"Total";
  UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 
                                                           0, 
                                                           self.view.frame.size.width, 
                                                           18)]autorelease];
  [view addSubview:lbl];
  [view addSubview:lbl1];
  [view addSubview:lbl2];
  self.tableView.tableHeaderView = view; 
}


- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.numberOfButtons-1) return;  
  switch (buttonIndex) {
    case 0:
      [self exportTimesAsCSV];
      break;      
    case 1:
      [self resetTimes];
      break;      
    default:
      break;
  }
}


- (void) showActionSheet {
  UIActionSheet *as = [[[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Reset", nil]autorelease];
  [as showInView:self.view];
}


- (void)loadView {
  [super loadView];
  [SWPStyle setStyleForNavBar:self.navigationController.navigationBar];
  self.title = @"Times";
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Stopwatch" 
                                                                           style:UIBarButtonItemStyleBordered target:self 
                                                                          action:@selector(showStopwatch)]autorelease];
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Options" 
                                                                           style:UIBarButtonItemStyleBordered target:self 
                                                                          action:@selector(showActionSheet)]autorelease];
  [self addHeader];
}


- (void) viewDidUnload {
  [super viewDidUnload];
}


- (void) setTotals {
  if (!cumulativeTotals) {
    self.cumulativeTotals = [NSMutableArray arrayWithCapacity:[[times objectForKey:@"timeList"]count]];
    for (int x=0;x<[[times objectForKey:@"timeList"]count];x++) {
      float total = [[[[times objectForKey:@"timeList"]objectAtIndex:x]objectForKey:@"seconds"]floatValue];
      if (x > 0) {
        total += [[self.cumulativeTotals objectAtIndex:x-1]floatValue];
      }
      [self.cumulativeTotals addObject:F(total)];
    }
    
  }
}


- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];  
  [self.tableView reloadData];
  [self setTotals];
}


- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}


- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {	
  // do nothing
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle != UITableViewCellEditingStyleDelete) { return; }
  
  NSMutableArray *timeList = [times objectForKey:@"timeList"];
  int timeIndex = [[times objectForKey:@"timeList"]count]-indexPath.row-1;
  [timeList removeObjectAtIndex:timeIndex];
  [times setObject:timeList forKey:@"timeList"];
  self.cumulativeTotals = nil;
  [self setTotals];
  [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
  [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[times objectForKey:@"timeList"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *CellIdentifier = @"TimeCell";
  SWPTimeCell *cell = (SWPTimeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
  RoundedGradientCellBackground *bgView;
  if (cell == nil) {
    bgView = [[[RoundedGradientCellBackground alloc] initWithFrame:CGRectZero]autorelease];
    cell = [[[SWPTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.backgroundView = bgView;
  }
  bgView = (RoundedGradientCellBackground*)cell.backgroundView;
  int row = indexPath.row;
  if (row == 0) {
    bgView.position = UACellBackgroundViewPositionTop;
  } else if (row == [[times objectForKey:@"timeList"] count]-1) {
    bgView.position = UACellBackgroundViewPositionBottom;
  } else {
    bgView.position = UACellBackgroundViewPositionMiddle;
  }
  
  int timeIndex = [[times objectForKey:@"timeList"]count]-indexPath.row-1;
  NSDictionary *timeDict = [[times objectForKey:@"timeList"]objectAtIndex:timeIndex];
  
  [cell setTimeForDict:timeDict totalTime:[[cumulativeTotals objectAtIndex:timeIndex] floatValue]];
	return cell;
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {  
  return YES;
}  

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fio {
  [self.tableView reloadData];
}


@end
