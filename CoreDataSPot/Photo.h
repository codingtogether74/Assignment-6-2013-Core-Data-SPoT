//
//  Photo.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/18/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoTag, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * dateView;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * thumnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *photoTags;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addPhotoTagsObject:(PhotoTag *)value;
- (void)removePhotoTagsObject:(PhotoTag *)value;
- (void)addPhotoTags:(NSSet *)values;
- (void)removePhotoTags:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
