//
//  PhotoTag.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Tag;

@interface PhotoTag : NSManagedObject

@property (nonatomic, retain) NSString * nameTag;
@property (nonatomic, retain) NSString * uniquePhoto;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) Tag *tag;

@end
