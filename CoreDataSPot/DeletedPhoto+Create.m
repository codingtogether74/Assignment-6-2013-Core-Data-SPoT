//
//  DeletedPhoto+Create.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/13/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "DeletedPhoto+Create.h"
#import "Photo+flickr.h"

@implementation DeletedPhoto (Create)
+(DeletedPhoto *)insertDeletedPhoto:(Photo *)photo
{
    DeletedPhoto *deletedPhoto = nil;
    NSManagedObjectContext *context = photo.managedObjectContext;

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"DeletedPhoto"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique =%@",photo.unique];
    NSSortDescriptor *sortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors =[NSArray arrayWithObject:sortDesciptor];
    
    NSError *error =nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count]>1) {
        //handl error
    } else if ([matches count]==0) {
        deletedPhoto =[NSEntityDescription insertNewObjectForEntityForName:@"DeletedPhoto" inManagedObjectContext:context];
        deletedPhoto.unique = photo.unique;
        deletedPhoto.title = photo.title;
        deletedPhoto.subtitle =photo.subtitle;
        deletedPhoto.imageURL = photo.imageURL;
        deletedPhoto.thumnailURL = photo.thumnailURL;
        deletedPhoto.thumbnailData = photo.thumbnailData;
        deletedPhoto.dateDelete = [NSDate date];
        [context insertObject:deletedPhoto];

    } else {
        deletedPhoto= [matches lastObject];
    }
    
    return deletedPhoto;
}


@end
