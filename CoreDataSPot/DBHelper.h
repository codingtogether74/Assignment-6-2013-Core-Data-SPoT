//
//  DBHelper.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/8/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface DBHelper : NSObject


@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) UIManagedDocument *database;
@property (nonatomic, strong) NSFileManager *fileManager;

+ (DBHelper *)sharedManagedDocument;
- (void)openDBUsingBlock:(void (^)(BOOL success))block;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end
