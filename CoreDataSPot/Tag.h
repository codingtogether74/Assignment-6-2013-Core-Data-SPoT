//
//  Tag.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/13/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, PhotoTag;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *photoTags;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPhotoTagsObject:(PhotoTag *)value;
- (void)removePhotoTagsObject:(PhotoTag *)value;
- (void)addPhotoTags:(NSSet *)values;
- (void)removePhotoTags:(NSSet *)values;

@end
