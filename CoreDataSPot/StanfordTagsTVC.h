//
//  StanfordTagsTVC.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "FlickrFetcher.h"

@interface StanfordTagsTVC : CoreDataTableViewController

@property (nonatomic, strong) UIManagedDocument *photoDatabase;

@end
