//
//  DeletedPhoto.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/19/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeletedPhoto : NSManagedObject

@property (nonatomic, retain) NSDate * dateDelete;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * thumnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;

@end
