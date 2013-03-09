//
//  SplitViewsManager.h
//  SPoT_PH
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//
//  Generic.
//  Will play the role of delegate if in a split view.
//  Will do split view bar button dance as long as
//    the detail view controller implements UISplitViewControllerDelegate.

#import <UIKit/UIKit.h>

@interface SplitViewsManager : UITableViewController <UISplitViewControllerDelegate>
- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController;

@end
