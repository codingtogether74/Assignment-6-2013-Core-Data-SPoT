//
//  PhotoTag+Insert.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/10/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PhotoTag.h"

@interface PhotoTag (Insert)
+ (NSSet *)photoTagsFromFlickrInfo:(NSDictionary *)flickrInfo
            inManagedObjectContext:(NSManagedObjectContext *)context;
@end
