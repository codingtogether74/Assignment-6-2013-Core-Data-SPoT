//
//  ImageViewController.h
//  Shutterbug
//
//  Created by Tatiana Kornilova on 2/22/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface ImageViewController : UIViewController<SplitViewBarButtonItemPresenter>
// the Model for this VC
// simply the URL of a UIImage-compatible image (jpg, png, etc.)

@property (nonatomic,strong) NSURL *imageURL;

@end
