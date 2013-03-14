//
//  Photo+flickr.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Photo.h"
#import "DeletedPhoto.h"

#define ALL_PHOTO_TAG_NAME @"$$$$"// make up some characters that will always stay on top of list

@interface Photo (flickr)

+(Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Photo *)exisitingPhotoWithID:(NSString *)photoID
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removePhoto:(Photo *)photo;
+ (void)removePhotoWithID:(NSString *)photoID
   inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)putToResents:(Photo *)photo;

@end
