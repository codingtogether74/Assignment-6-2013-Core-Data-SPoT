//
//  Photo.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoTag, Tag, Thumnail;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * dateView;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *photoTags;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Thumnail *thumnail;
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
