//
//  Thumnail.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Thumnail : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) Photo *photo;

@end
