//
//  Tag+Create.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)
+ (NSSet *)tagsFromFlickrInfo:(NSDictionary *)flickrInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;
@end
