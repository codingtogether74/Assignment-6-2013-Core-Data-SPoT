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
        } else {
            tag = [matches lastObject];  
        }
        //----------- Add the tag to the set.----------
        if (tag) [tags addObject:tag];
    }
     return tags;
}
// Sort photos in Tags before use in NSFetchedResultsController
+ (void)sortPhotosInTagsinManagedObjectContext:(NSManagedObjectContext *)context


{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"photos.@count > 1"];
    NSArray *tags = [context executeFetchRequest:request error:NULL];
    for (Tag *tag in tags) {
        NSMutableOrderedSet *photos = [tag.photos mutableCopy];
        NSArray *sortedPhotos = [photos sortedArrayUsingComparator:
                                 ^NSComparisonResult(Photo *photo1, Photo *photo2) {
                                     NSString *first = photo1.title;
                                     NSString *second = photo2.title;
                                     return [first caseInsensitiveCompare:second];
                                 }];
        tag.photos =[NSOrderedSet orderedSetWithArray: sortedPhotos];
    }
}


@end
