//
//  SWPCountdownPicker.m
//  StopWatch+
//
//  Created by Andrew L. Johnson on 6/3/12.
//  Copyright (c) 2012 TrailBehind, Inc. All rights reserved.
//

#import "SWPCountdownPicker.h"
#import "SWPConstants.h"
#import "SWPAppDelegate.h"
#import "SWPViewController.h"
#import "SWPStyle.h"

#define PICKER_TAG 999


@implementation SWPCountdownPicker

- (void) addAndInitPicker:(CGRect)frame {
  UIPickerView *picker = [[[UIPickerView alloc] init]autorelease];
  picker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  picker.frame = frame;
  picker.delegate = self;
  picker.tag = PICKER_TAG;
  picker.dataSource = self;
  picker.showsSelectionIndicator = YES;
  [self.view addSubview:picker];
}  


- (void) begin {
  UIPickerView *pv = (UIPickerView*)[self.view viewWithTag:PICKER_TAG];
  [(SWPViewController*)self.presentingViewController countdown:[pv selectedRowInComponent:0]*3600
   + [pv selectedRowInComponent:1]*60
   + [pv selectedRowInComponent:2]*1];
}


- (void) cancel {
  [self.presentingViewController dismissModalViewControllerAnimated:YES];  
}


- (void)loadView {
	[super loadView];
  [SWPStyle setStyleForNavBar:self.navigationController.navigationBar];
  self.title = @"Countdown";
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)]autorelease];
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"Ready" style:UIBarButtonItemStyleDone target:self action:@selector(begin)]autorelease];	[self addAndInitPicker:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height)];
  
  UILabel *lbl = [[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-300/2, 10, 300, 30)]autorelease];
  lbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  lbl.backgroundColor = [UIColor clearColor];
  lbl.textColor = [SWPStyle textColor];
  lbl.font = HBOLD(24);
  lbl.shadowColor = [UIColor whiteColor];
  lbl.shadowOffset = CGSizeMake(0, -1.0);
  [self.view addSubview: lbl];
  lbl.text = @"   Hours    Min     Sec";
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *retval = (UILabel*)view;
	if (!retval) {
		retval= [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 50.0)] autorelease];
    retval.lineBreakMode = UILineBreakModeWordWrap;
    retval.textAlignment = UITextAlignmentCenter;
    retval.adjustsFontSizeToFitWidth = YES;
    retval.backgroundColor = [UIColor clearColor];
  }
  retval.text = [NSString stringWithFormat:@"%d", row];
	return retval;	
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  return 80;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  if (component == 0) {
    return 11;     
  } else {
    return 61;
    
  }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {  
}


@end
