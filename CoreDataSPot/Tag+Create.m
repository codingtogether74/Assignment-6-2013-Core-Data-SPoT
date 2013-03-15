//
//  Tag+Create.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Tag+Create.h"
#import "FlickrFetcher.h"
#import "Photo+flickr.h"

@interface Tag ()

@end
@implementation Tag (Create)

+ (NSSet *)tagsFromFlickrInfo:(NSDictionary *)flickrInfo
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *ignoredTags =@[@"cs193pspot", @"portrait", @"landscape"];
    NSMutableArray *tagStrings = [[[flickrInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
    [tagStrings  removeObjectsInArray:ignoredTags];
    [tagStrings  addObject:ALL_PHOTO_TAG_NAME];
    if (![tagStrings count]) return nil;
    
    //---------- Build fetch request.-----------
    NSFetchRequest *request           = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors           = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
  
    Tag *tag;
    NSMutableSet *tags = [NSMutableSet  setWithCapacity:[tagStrings count]];
    for (NSString *tagName in tagStrings) {
        tag = nil;
        if (!tagName || [tagName isEqualToString:@""]) continue;
        //---------- Build fetch request.-----------
        request.predicate             = [NSPredicate predicateWithFormat:@"name = %@", [tagName capitalizedString]];
        //---------- Execute fetch request.-----------
         NSError *error =nil;
         NSArray *matches = [context executeFetchRequest:request error:&error];

        if (!matches || ([matches count] > 1) || error) {
            NSLog(@"Error in tagsFromFlickrInfo: %@ %@", matches, error);
        } else if ([matches count] == 0) {
            //------------- Create new tag if one doesn't already exist, otherwise retrieve the tag already on-file.
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                inManagedObjectContext:context];
            tag.name = [tagName capitalizedString];
            tag.count =  @1;//[NSNumber numberWithInt:1];
        } else {
            tag = [matches lastObject];
            tag.count = [NSNumber numberWithInt:[tag.count intValue] + 1];    
        }
        //----------- Add the tag to the set.----------
        if (tag) [tags addObject:tag];
    }
    return tags;
}


@end
