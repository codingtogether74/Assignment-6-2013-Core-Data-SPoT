//
//  FlickrPhotoTVC.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "CoreDataTableViewController.h"

@interface FlickrPhotoTVC : CoreDataTableViewController;
@property (nonatomic,strong) Tag *tag;
@end
