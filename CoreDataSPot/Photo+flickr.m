//
//  Photo+flickr.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Photo+flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"
#import "PhotoTag+Insert.h"
#import "DeletedPhoto+Create.h"
#import "Thumnail.h"

@implementation Photo (flickr)
+(Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique =%@",[flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors =[NSArray arrayWithObject:sortDesciptor];
    
    NSError *error =nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count]>1) {
        //handl error
    } else if ([matches count]==0) {
        photo =[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle =[flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumnailURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatSquare] absoluteString];
        photo.tags = [Tag tagsFromFlickrInfo:flickrInfo inManagedObjectContext:context];
        photo.photoTags = [PhotoTag photoTagsFromFlickrInfo:flickrInfo inManagedObjectContext:context];
        [self updateTagsForPhoto:photo];

        } else {
        photo =[matches lastObject];
    }
    return photo;
}
+ (Photo *)exisitingPhotoWithID:(NSString *)photoID
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", photoID];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                             ascending:YES]];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1 || error)) {
        NSLog(@"Error in exisitingPhotoForID: %@ %@", matches, error);
    } else if ([matches count] == 0) {
        photo = nil;
    } else {
        photo = [matches lastObject];
    }
    return photo;
}

+ (void)removePhoto:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    // tags could be put in prepareForDeletion
    for (Tag *tag in photo.tags) {
        if ([tag.photos count] == 1) [context deleteObject:tag];
        else tag.count = [NSNumber numberWithInt:[tag.photos count] - 1];
    }
    for (PhotoTag *photoTag in photo.photoTags) {
        [context deleteObject:photoTag];
     }
 
    [DeletedPhoto insertDeletedPhoto:photo];
    [context deleteObject:photo];
}

+ (void)putToResents:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    [Photo exisitingPhotoWithID:photo.unique inManagedObjectContext:context].dateView = [NSDate date];
       [context updatedObjects];
}

+ (void)removePhotoWithID:(NSString *)photoID
   inManagedObjectContext:(NSManagedObjectContext *)context
{
    [Photo removePhoto:[Photo exisitingPhotoWithID:photoID inManagedObjectContext:context]];
}

+(void)updateTagsForPhoto:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    NSSet *tags =photo.tags;
    for (Tag *tag in tags) {
        NSMutableOrderedSet *photos = [tag.photos mutableCopy];
        NSArray *sortedPhotos = [photos sortedArrayUsingComparator:
                                 ^NSComparisonResult(Photo *photo1, Photo *photo2) {
                                     NSString *first = photo1.title;
                                     NSString *second = photo2.title;
                                     return [first caseInsensitiveCompare:second];
                                 }];
        tag.photos =[NSOrderedSet orderedSetWithArray:sortedPhotos ];
        
    }
    [context updatedObjects];
}
@end
