//
//  DBHelper.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/8/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "DBHelper.h"

#define DEFAULT_DB_NAME @"Stanford Photos Database"

@implementation DBHelper

@synthesize dbName =_dbName;
//----------------------------------------------------------------
# pragma mark   -   Accessors
//----------------------------------------------------------------

- (NSFileManager *)fileManager
{
    if (!_fileManager) _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

- (UIManagedDocument *)database
{
    if (!_database) {
        NSFileManager *fm = self.fileManager;
        NSURL *baseDir=[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _database = [[UIManagedDocument alloc] initWithFileURL:
                     [baseDir URLByAppendingPathComponent:self.dbName]];
    }
    return _database;
}

-(void)setDbName:(NSString *)dbName
{
    if (_dbName != dbName) {
        _dbName = dbName;
        self.database =nil;
    }

}
- (NSString *)dbName
{
    if (!_dbName) {
        _dbName = DEFAULT_DB_NAME;
    }
    return _dbName;
}


+ (DBHelper *)sharedManagedDocument
{
    //----- It's a singleton --------------------------------------------
    static dispatch_once_t pred = 0;
    __strong static DBHelper *_sharedManagedDocument = nil;
    dispatch_once(&pred, ^{
        _sharedManagedDocument = [[self alloc] init];
    });
    return _sharedManagedDocument;
}

//----------------------------------------------------------------
# pragma mark   -   DBHelper methods
//----------------------------------------------------------------

- (void)openDBUsingBlock:(void (^)(BOOL))block
{
    DBHelper *dbh = [DBHelper sharedManagedDocument];
    if (![dbh.fileManager fileExistsAtPath:[dbh.database.fileURL path]]) {
        [dbh.database saveToURL:dbh.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:block];
    } else if (dbh.database.documentState == UIDocumentStateClosed) {
        [dbh.database openWithCompletionHandler:block];
    } else {
        BOOL success = YES;
        block(success);
    }
}

- (void)performWithDocument:(OnDocumentReady)onDocumentReady{
    void (^OnDocumentDidLoad)(BOOL) =^(BOOL success) {
        onDocumentReady(self.database);    };
    if (![self.fileManager fileExistsAtPath:[self.database.fileURL path]]){
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating  completionHandler:OnDocumentDidLoad];
    } else if (self.database.documentState == UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:OnDocumentDidLoad];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        OnDocumentDidLoad(YES);
    }}


@end
