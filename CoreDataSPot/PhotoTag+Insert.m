//
//  PhotoTag+Insert.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/10/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PhotoTag+Insert.h"
#import "Photo+flickr.h"
#import "FlickrFetcher.h"

@implementation PhotoTag (Insert)
+ (NSSet *)photoTagsFromFlickrInfo:(NSDictionary *)flickrInfo
            inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *uniquePhoto = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
    NSArray *ignoredTags =@[@"cs193pspot", @"portrait", @"landscape"];
    NSMutableArray *tagStrings = [[[flickrInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
    [tagStrings  removeObjectsInArray:ignoredTags];
    if (![tagStrings count]) return nil;
    
    //---------- Build fetch request.-----------
    NSFetchRequest *request           = [NSFetchRequest fetchRequestWithEntityName:@"PhotoTag"];
    request.sortDescriptors           = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"nameTag" ascending:YES]];
    
    
    PhotoTag *photoTag;
    NSMutableSet *photoTags = [NSMutableSet setWithCapacity:[tagStrings count]];
    for (NSString *tagName in tagStrings) {
        photoTag = nil;
        if (!tagName || [tagName isEqualToString:@""]) continue;
        //---------- Build fetch request.-----------
        request.predicate             = [NSPredicate predicateWithFormat:@"nameTag = %@ AND uniquePhoto =%@", [tagName capitalizedString],uniquePhoto];
        //---------- Execute fetch request.-----------
        NSError *error =nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] >1) || error) {
            NSLog(@"Error in tagsFromFlickrInfo: %@ %@", matches, error);
        } else if ([matches count] == 0) {
            //------------- Create new photoTag if one doesn't already exist, otherwise retrieve the tag already on-file.
            photoTag = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoTag"
                                                     inManagedObjectContext:context];
            photoTag.nameTag = [tagName capitalizedString];
            photoTag.uniquePhoto =  uniquePhoto;
            
        } else {
            photoTag = [matches lastObject];
        }
        //----------- Add the photoTag to the set.----------
        if (photoTag) [photoTags addObject:photoTag];
    }
    return photoTags;
}

@end
