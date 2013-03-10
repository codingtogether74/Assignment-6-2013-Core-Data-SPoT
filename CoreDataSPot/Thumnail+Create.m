//
//  Thumnail+Create.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/9/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Thumnail+Create.h"
#import "Photo+flickr.h"

@implementation Thumnail (Create)

+ (void)insertThumnail:(NSData *)imageData forPhoto:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    Thumnail *thumnail =nil;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Thumnail"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique =%@",photo.unique];
    
    NSError *error =nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count]>=1) {
        //handl error
    } else if ([matches count]==0) {
        thumnail =[NSEntityDescription insertNewObjectForEntityForName:@"Thumnail" inManagedObjectContext:context];
        thumnail .unique = photo.unique;
        thumnail.imageData = imageData;
        thumnail.photo = [Photo exisitingPhotoWithID:photo.unique inManagedObjectContext:context];
        [context insertObject:thumnail];
    }
}

+ (NSData *)imageDataThumnailForPhoto:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    NSData *imageData =nil;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Thumnail"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique =%@",photo.unique];
    
    NSError *error =nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count]>1) {
        //handl error
    } else if ([matches count]==1) {
  
        Thumnail *thumnail = [matches lastObject];
        imageData =thumnail.imageData;
    }
    return imageData;
}
@end
