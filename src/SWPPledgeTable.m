//
//  SWPPledgeTable.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/16/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPPledgeTable.h"
#import "SWPPledgeWall.h"
#import "SWPAppDelegate.h"
#import "SWPPledgeWall.h"
#import "SWPConstants.h"
#import "SavingDictionary.h"
#import "SWPPurchaseController.h"
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

#define BRONZE_INDEX 0
#define SILVER_INDEX 1
#define RESTORE_TAG 987

@implementation SWPPledgeTable
@synthesize pledgeProducts, pledgeField, buyRow;

- (void)dealloc {
  [pledgeField release];
  [pledgeProducts release];
	[super dealloc];
}


- (UILabel*) labelWithFrame:(CGRect)frame {
  UILabel *label = [[[UILabel alloc]initWithFrame:frame]autorelease];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  label.backgroundColor = [UIColor clearColor];
  label.shadowColor = [UIColor whiteColor];
  label.numberOfLines = 0;
  return label;
}


- (void) addTableHeader {
  CGRect containerFrame = CGRectMake(0, 0, self.view.frame.size.width-20, 105);
  CGRect headerFrame = CGRectMake(10, 10, containerFrame.size.width-20, 100);
  CGRect titleLabelFrame = CGRectMake(10, 10, headerFrame.size.width-20, 24);
  CGRect descriptionLabelFrame = CGRectMake(10, 40, headerFrame.size.width-20, 55);
  
  UIView *container = [[[UIView alloc]initWithFrame:containerFrame]autorelease];
  container.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  UIView *headerView = [[[UIView alloc]initWithFrame:headerFrame]autorelease];
  headerView.layer.cornerRadius = 4;
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  headerView.layer.borderWidth = 1;
  headerView.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]CGColor];
  headerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.6];
  [container addSubview:headerView];
  self.tableView.tableHeaderView = container;
  
  UILabel *titleLabel = [self labelWithFrame:titleLabelFrame];
  titleLabel.text = @"Why pledge?";
  titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
  [headerView addSubview:titleLabel];
  
  UILabel *descriptionLabel = [self labelWithFrame:descriptionLabelFrame];
  descriptionLabel.text = @"* this app is ad-free and cost-free\n* supporters get access to an exclusive color pack\n";
  descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
  [headerView addSubview:descriptionLabel];
}


- (void) addTableFooter {
  CGRect footerLabelFrame = CGRectMake(10, 0, self.view.frame.size.width-20, 12);
  UILabel *footerLabel = [self labelWithFrame:footerLabelFrame];
  footerLabel.text = @"Obscenity is prohibited. Messages are moderated.";
  footerLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
  footerLabel.textAlignment = UITextAlignmentCenter;
  self.tableView.tableFooterView = footerLabel;
}


- (void) restorePurchases {
  UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Restore Purchases" message:@"If you have previously pledged and deleted the app, touching this button will make the app remember you pledged." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Restore", nil]autorelease];
  av.tag = RESTORE_TAG;
  [av show];
}


- (void) viewDidLoad {
  [super viewDidLoad];
  self.title = @"Pledges";  
  [self addTableHeader];  
  [self addTableFooter];
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  self.pledgeProducts = a.purchaseController.products;  
  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"price"
                                                ascending:YES] autorelease];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  self.pledgeProducts = (NSMutableArray*)[pledgeProducts sortedArrayUsingDescriptors:sortDescriptors];
  [self.tableView reloadData];
  
  if ([SETTINGS_DICT objectForKey:BOWSER_PURCHASED]) {
    return;
  }
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restorePurchases)]autorelease];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellID = @"Cell";
  UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  SKProduct *p = [self.pledgeProducts objectAtIndex:indexPath.row];
    cell.textLabel.text = p.localizedTitle;
  cell.textLabel.backgroundColor = [UIColor clearColor];
  cell.detailTextLabel.backgroundColor = [UIColor clearColor];
  cell.detailTextLabel.textColor = [UIColor blackColor];
  cell.detailTextLabel.text = p.localizedDescription;
  cell.detailTextLabel.numberOfLines = 0;
  NSString *priceString = [NSString stringWithFormat:@"%@", p.price];
  
  UISegmentedControl *buyButton = [[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObject:priceString]]autorelease];
  buyButton.segmentedControlStyle = UISegmentedControlStyleBar;
  buyButton.momentary = YES;
  buyButton.tag = indexPath.row;
  [buyButton addTarget:self 
                action:@selector(buyButtonPressed:) 
      forControlEvents:UIControlEventValueChanged];
  cell.accessoryView = buyButton;
  if (indexPath.row == BRONZE_INDEX) {
    cell.backgroundColor = BRONZE_COLOR;   
    buyButton.tintColor = BRONZE_COLOR;
  } else if (indexPath.row == SILVER_INDEX) {
    cell.backgroundColor = SILVER_COLOR;    
    buyButton.tintColor = [UIColor grayColor];
  } else {
    buyButton.tintColor = DARK_GOLD_COLOR;
    cell.backgroundColor = GOLD_COLOR;      
  }

  return cell;
}


- (void) buyButtonPressed:(UISegmentedControl*)sender {
  [self buyProduct:sender.tag];
}


- (void) buyProduct:(int)row {
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  if (!a.purchaseController.products || [a.purchaseController.products count] == 0) {
    UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Not Available" message:@"Bowser Skin is not available right now. Please try again in a moment, or when you get a better internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil]autorelease];
    [av show];
    return;
  }
  UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Enter your message."
                                                        message:@"this gets covered" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  pledgeField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
  [pledgeField setBackgroundColor:[UIColor whiteColor]];
  [myAlertView addSubview:pledgeField];
  [myAlertView show];
  [pledgeField becomeFirstResponder];
  [myAlertView release];
  buyRow = row;
}


- (void) addPledge {
  PFObject *pledge = [PFObject objectWithClassName:@"Pledge"];
  [pledge setObject:N(buyRow) forKey:@"level"];
  [pledge setObject:pledgeField.text forKey:@"message"];
  [pledge setObject:[NSDate date] forKey:@"createdOnDevice"];
  [pledge save];
  [pledgeField release];
  pledgeField = nil;
  UIAlertView *myAlertView = [[[UIAlertView alloc] initWithTitle:@"Thanks for Pledging"
                                                         message:@"You can now find your message on the wall. You can pledge many times if you really dig StopWatch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
  [myAlertView show];
  SavingDictionary *settingsDict = SETTINGS_DICT;   
  [settingsDict setObject:N(YES) forKey:BOWSER_PURCHASED];
  [(SWPPledgeWall*)[[self.navigationController viewControllers]objectAtIndex:1]setPledges:nil];
  [[[self.navigationController viewControllers]objectAtIndex:1]setPledgeCount:FLAGGED_FOR_REFRESH];
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet.tag == RESTORE_TAG) {
    if (buttonIndex == 0) return;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    return;
  }
  if (!pledgeField.text || [pledgeField.text isEqual:@""]) {
    [self buyProduct:buyRow];
    return;
  }
  SKProduct *selectedProduct = [self.pledgeProducts objectAtIndex:buyRow];
  SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
	return 90.0;  
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [pledgeProducts count];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {  
  return YES;
} 

@end
