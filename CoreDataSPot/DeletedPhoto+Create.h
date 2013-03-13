//
//  DeletedPhoto+Create.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/13/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "DeletedPhoto.h"
#import "Photo.h"

@interface DeletedPhoto (Create)
+ (DeletedPhoto *)insertDeletedPhoto:(Photo *)photo;

@end
