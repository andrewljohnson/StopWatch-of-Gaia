//
//  SWPPurchaseController.h
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/30/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SWPPurchaseController : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, retain) NSArray *products;

- (void) fetchProducts;
- (void) comeOnPromptMeMaybe;

@end
