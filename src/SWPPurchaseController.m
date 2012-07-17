//
//  SWPPurchaseController.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/30/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPPurchaseController.h"
#import "SWPAppDelegate.h"
#import "SWPPledgeTable.h"
#import "SWPConstants.h"
#import "SWPSettingsTableVC.h"
#import "SavingDictionary.h"
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>


@implementation SWPPurchaseController
@synthesize products;

- (void)dealloc {  
  [products release];
  [super dealloc];
}


- (void) promptToBuy {
  if ([SETTINGS_DICT objectForKey:BOWSER_PURCHASED]) {
    return;
  }
  UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Pledge Today" message:@"The app is totally ad and cost free. You can support us by leaving a message on the Pledge Wall." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
  [av show];
}


- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {    
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  [a.viewController showPledgeWall];
}


#define BUG_ME_DAYS_DEFAULT 10
// prompt the user to pledge, control time between prompts via Parse dashboard
- (void) comeOnPromptMeMaybe {
  SavingDictionary *settingsDict = SETTINGS_DICT;    
  int launches = [[settingsDict objectForKey:@"LAUNCHES"]intValue];
  if (launches <=0) {
    launches = 1;
  } else {
    launches++;
  }
  PFQuery *query = [PFQuery queryWithClassName:@"NumberOfLoads"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    int bugMeDays = BUG_ME_DAYS_DEFAULT;
    if (!error) {
      bugMeDays = [[[objects objectAtIndex:0]objectForKey:@"loads"]intValue];
    } else {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
    if (launches < bugMeDays) {
      [settingsDict setObject:N(launches) forKey:@"LAUNCHES"];        
    } else {
      [settingsDict setObject:N(0) forKey:@"LAUNCHES"];
      [self promptToBuy];
    }
  }];  
}


# pragma mark - SKProduct delegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  NSArray *myProducts = response.products;
  self.products = myProducts;
}


- (void) fetchProducts {
  SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                [NSSet setWithObjects: @"com.trailbehind.pw.bronze", @"com.trailbehind.pw.silver", @"com.trailbehind.pw.gold", nil]];
  request.delegate = self;
  [request start];
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      case SKPaymentTransactionStateRestored:
        [self restoreTransaction:transaction];
      default:
        break;
    }
  }
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction {
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  [a.pledgeTable addPledge];
  SavingDictionary *settingsDict = SETTINGS_DICT;    
  [settingsDict setObject:@"YES" forKey:BOWSER_PURCHASED];
  [settingsDict setObject:@"YES" forKey:BOWSER_KEY];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  [a.settingsScreen switchSkins];
}


// unused function now
- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
  SavingDictionary *settingsDict = SETTINGS_DICT;    
  [settingsDict setObject:@"YES" forKey:BOWSER_PURCHASED];
  [settingsDict setObject:@"YES" forKey:BOWSER_KEY];
  SWPAppDelegate *a = (SWPAppDelegate *)[[UIApplication sharedApplication] delegate];
  [a.settingsScreen switchSkins];
}


// unused function now
- (void) failedTransaction: (SKPaymentTransaction *)transaction {
  // if (transaction.error.code != SKErrorPaymentCancelled) {
  // Optionally, display an error here.
  // }
  // [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


@end
